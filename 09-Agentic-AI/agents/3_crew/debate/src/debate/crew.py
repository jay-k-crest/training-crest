from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
import os
from dotenv import load_dotenv
from pinecone import Pinecone
import time
import json
import uuid
import random
from typing import Dict, Any

load_dotenv()

class PineconeMemory:
    """Simple custom memory using Pinecone only - NO ChromaDB dependency"""
    
    def __init__(self):
        # Initialize Pinecone
        api_key = os.getenv("PINECONE_API_KEY")
        if not api_key:
            raise ValueError("PINECONE_API_KEY not found in environment variables")
            
        self.pc = Pinecone(api_key=api_key)
        self.index_name = "debate-memory"
        self.namespace = "debates"
        
        # Connect to existing index
        if self.index_name not in self.pc.list_indexes().names():
            raise ValueError(f"Index {self.index_name} not found. Run create_pinecone_index.py first")
        
        self.index = self.pc.Index(self.index_name)
        print(f"✅ Connected to Pinecone index: {self.index_name}")
        
        # In-memory cache for current conversation
        self.current_conversation = []
    
    def _generate_mock_embedding(self) -> list:
        """Generate a mock embedding with at least one non-zero value"""
        embedding = [0.0] * 1024
        embedding[random.randint(0, 1023)] = 0.000001
        return embedding
    
    def add_to_conversation(self, role: str, content: str):
        """Add a message to the current conversation"""
        self.current_conversation.append({
            "role": role,
            "content": content,
            "timestamp": time.time()
        })
        
        # Also save to Pinecone for long-term memory
        self._save_to_pinecone(role, content)
    
    def _save_to_pinecone(self, role: str, content: str):
        """Save to Pinecone for long-term storage"""
        record_id = f"{role}-{int(time.time())}-{uuid.uuid4().hex[:8]}"
        
        # Generate mock embedding with non-zero value
        mock_embedding = self._generate_mock_embedding()
        
        # Prepare metadata
        metadata = {
            "role": role,
            "content": content[:500],  # Truncate for metadata
            "timestamp": time.time(),
            "type": "debate_argument"
        }
        
        # Upsert to Pinecone
        self.index.upsert(
            vectors=[{
                "id": record_id,
                "values": mock_embedding,
                "metadata": metadata
            }],
            namespace=self.namespace
        )
    
    def get_conversation_history(self) -> str:
        """Get the current conversation history as a string"""
        if not self.current_conversation:
            return "No conversation history yet."
        
        history = []
        for msg in self.current_conversation:
            history.append(f"{msg['role'].upper()}: {msg['content']}")
        
        return "\n\n".join(history)
    
    def get_relevant_history(self, query: str, limit: int = 3) -> str:
        """Get relevant past debates from Pinecone"""
        try:
            # Generate mock embedding for query
            mock_embedding = self._generate_mock_embedding()
            
            results = self.index.query(
                vector=mock_embedding,
                top_k=limit,
                include_metadata=True,
                filter={"type": {"$eq": "debate_argument"}},
                namespace=self.namespace
            )
            
            if not results or not results.matches:
                return "No past debates found."
            
            history = []
            for match in results.matches:
                if match.metadata:
                    role = match.metadata.get("role", "unknown")
                    content = match.metadata.get("content", "")
                    if content and len(content) > 10:
                        history.append(f"Past {role.upper()}: {content}")
            
            return "\n\n".join(history) if history else "No relevant past debates."
        except Exception as e:
            print(f"⚠️ Error getting history: {e}")
            return "Error retrieving past debates."
    
    def get_context_for_task(self, task_description: str) -> Dict[str, str]:
        """Get memory context for a task"""
        return {
            "conversation_history": self.get_conversation_history(),
            "past_debates": self.get_relevant_history(task_description)
        }

@CrewBase
class Debate():
    """Debate crew with Pinecone memory (NO ChromaDB)"""

    agents_config = 'config/agents.yaml'
    tasks_config = 'config/tasks.yaml'

    def __init__(self):
        self.memory = PineconeMemory()

    @agent
    def debater(self) -> Agent:
        return Agent(
            config=self.agents_config['debater'],
            verbose=True
        )

    @agent
    def judge(self) -> Agent:
        return Agent(
            config=self.agents_config['judge'],
            verbose=True
        )

    @task
    def propose(self) -> Task:
        return Task(
            config=self.tasks_config['propose'],
        )

    @task
    def oppose(self) -> Task:
        return Task(
            config=self.tasks_config['oppose'],
        )

    @task
    def decide(self) -> Task:
        return Task(
            config=self.tasks_config['decide'],
        )

    @crew
    def crew(self) -> Crew:
        """Creates the Debate crew"""
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True,
            memory=False,# Disable built-in memory system
             tracing=True
        )