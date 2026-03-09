#!/usr/bin/env python
import sys
import warnings
from pathlib import Path
from debate.crew import Debate
from dotenv import load_dotenv
import os
import time
import io

load_dotenv()

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

warnings.filterwarnings("ignore", category=SyntaxWarning, module="pysbd")

def run():
    """
    Run the crew with Pinecone memory (NO ChromaDB).
    """
    # Create output directory if it doesn't exist
    Path("output").mkdir(exist_ok=True)
    
    try:
        print("\n" + "="*60)
        print("🎭 DEBATE STARTING WITH PINECONE MEMORY")
        print("="*60 + "\n")
        
        # Check if Pinecone is configured
        if not os.getenv("PINECONE_API_KEY"):
            print("❌ PINECONE_API_KEY not found in .env file")
            return
            
        # Initialize debate
        debate = Debate()
        
        # Get memory context
        memory_context = debate.memory.get_context_for_task("debate")
        
        # Prepare inputs with memory context
        inputs = {
            'motion': 'There needs to be strict laws to regulate LLMs',
            'conversation_history': memory_context['conversation_history'],
            'past_debates': memory_context['past_debates']
        }
        
        print(f"📝 Motion: {inputs['motion']}")
        print(f"📚 Conversation history: {len(memory_context['conversation_history'])} chars")
        print(f"📚 Past debates: {len(memory_context['past_debates'])} chars\n")
        
        # Add initial context to memory
        debate.memory.add_to_conversation("system", f"Debate started on motion: {inputs['motion']}")
        
        # Run the debate
        result = debate.crew().kickoff(inputs=inputs)
        
        print("\n" + "="*60)
        print("🏆 DEBATE COMPLETE!")
        print("="*60)
        print("\n📄 Check output files in /output directory")
        
        # Save the results to memory
        for output_file in ["propose.md", "oppose.md", "decide.md"]:
            file_path = Path("output") / output_file
            if file_path.exists():
                with open(file_path, 'r',encoding='utf-8') as f:
                    content = f.read()
                    role = output_file.replace(".md", "")
                    debate.memory.add_to_conversation(role, content[:500])
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

def test_pinecone():
    """Test Pinecone connection with proper non-zero vectors"""
    print("\n🔍 Testing Pinecone connection...")
    try:
        from pinecone import Pinecone
        pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
        indexes = pc.list_indexes().names()
        print(f"✅ Connected to Pinecone!")
        print(f"📊 Available indexes: {indexes}")
        
        if "debate-memory" in indexes:
            print(f"✅ debate-memory index exists")
            index = pc.Index("debate-memory")
            stats = index.describe_index_stats()
            print(f"📊 Index stats: {stats}")
            
            # Test write with NON-ZERO vector
            test_id = f"test-{int(time.time())}"
            test_vector = [0.0] * 1024
            test_vector[42] = 0.001
            
            index.upsert(
                vectors=[{
                    "id": test_id,
                    "values": test_vector,
                    "metadata": {"test": "connection", "timestamp": time.time()}
                }],
                namespace="test"
            )
            print("✅ Successfully wrote to Pinecone")
            
            # Clean up
            index.delete(ids=[test_id], namespace="test")
            print("✅ Test data cleaned up")
            
        else:
            print("⚠️ debate-memory index not found")
    except Exception as e:
        print(f"❌ Pinecone connection failed: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        test_pinecone()
    else:
        run()