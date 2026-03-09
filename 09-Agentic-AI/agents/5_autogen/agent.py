from autogen_core import MessageContext, RoutedAgent, message_handler
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
from autogen_ext.models.openai import OpenAIChatCompletionClient
import messages
import random
import asyncio
from dotenv import load_dotenv
import os
from datetime import datetime, timedelta
import time

load_dotenv(override=True)

# Model configurations with their RPM and TPM limits - EXCLUDING moonshotai due to low TPM
MODELS = [
    {
        "name": "llama-3.3-70b-versatile",
        "rpm": 30,
        "tpm": 12000,
        "weight": 2.0,  # Increased weight
        "requests_per_second": 0.5
    },
    {
        "name": "meta-llama/llama-4-scout-17b-16e-instruct",
        "rpm": 30,
        "tpm": 30000,
        "weight": 5.0,  # Highest weight due to high TPM
        "requests_per_second": 0.5
    },
    {
        "name": "openai/gpt-oss-120b",
        "rpm": 30,
        "tpm": 8000,
        "weight": 1.5,
        "requests_per_second": 0.5
    },
    {
        "name": "qwen/qwen3-32b",
        "rpm": 60,
        "tpm": 6000,
        "weight": 1.0,
        "requests_per_second": 1.0
    },
    {
        "name": "llama-3.1-8b-instant",
        "rpm": 30,
        "tpm": 6000,
        "weight": 1.0,
        "requests_per_second": 0.5
    },
    {
        "name": "meta-llama/llama-4-maverick-17b-128e-instruct",
        "rpm": 30,
        "tpm": 6000,
        "weight": 1.0,
        "requests_per_second": 0.5
    }
]

# Token budget calculator with conservative estimation
class TokenBudget:
    def __init__(self):
        self.model_usage = {model["name"]: {"tokens": 0, "reset_time": datetime.now()} for model in MODELS}
        self.lock = asyncio.Lock()
    
    async def can_use_model(self, model_name: str, estimated_tokens: int = 500):
        async with self.lock:
            model_config = next((m for m in MODELS if m["name"] == model_name), None)
            if not model_config:
                return False
            
            now = datetime.now()
            usage = self.model_usage[model_name]
            
            # Reset if a minute has passed
            if now - usage["reset_time"] > timedelta(minutes=1):
                usage["tokens"] = 0
                usage["reset_time"] = now
            
            # Leave 20% buffer
            safe_limit = model_config["tpm"] * 0.8
            
            # Check if we have enough token budget
            if usage["tokens"] + estimated_tokens <= safe_limit:
                usage["tokens"] += estimated_tokens
                return True
            return False

# Global token budget tracker
_token_budget = TokenBudget()

# Rate limiter with per-model tracking
class RateLimiter:
    def __init__(self):
        self.model_requests = {}
        self.lock = asyncio.Lock()
    
    async def acquire(self, model_name: str):
        async with self.lock:
            model_config = next((m for m in MODELS if m["name"] == model_name), None)
            if not model_config:
                return
            
            now = datetime.now()
            
            if model_name not in self.model_requests:
                self.model_requests[model_name] = []
            
            # Clean up old requests
            self.model_requests[model_name] = [
                req_time for req_time in self.model_requests[model_name]
                if now - req_time < timedelta(minutes=1)
            ]
            
            # Leave 10% buffer on RPM
            safe_rpm = int(model_config["rpm"] * 0.9)
            
            # Check if we've hit the RPM limit
            if len(self.model_requests[model_name]) >= safe_rpm:
                # Calculate wait time
                oldest = self.model_requests[model_name][0]
                wait_time = 60 - (now - oldest).total_seconds()
                if wait_time > 0:
                    print(f"Rate limit for {model_name}, waiting {wait_time:.2f}s")
                    await asyncio.sleep(wait_time + 0.5)
                return await self.acquire(model_name)
            
            self.model_requests[model_name].append(now)
            return True

# Global rate limiter
_groq_rate_limiter = RateLimiter()

# Helper function to estimate tokens from text
def estimate_tokens(text: str) -> int:
    """Rough estimation: 1 token ≈ 4 characters for English"""
    return len(text) // 4

# Helper function to select model based on availability
async def select_available_model(estimated_tokens: int = 500):
    available_models = []
    for model in MODELS:
        if await _token_budget.can_use_model(model["name"], estimated_tokens):
            available_models.append(model)
    
    if not available_models:
        print("No models available with sufficient token budget, waiting...")
        await asyncio.sleep(5)
        return await select_available_model(estimated_tokens)
    
    # Weighted selection based on TPM
    total_weight = sum(model["weight"] for model in available_models)
    r = random.uniform(0, total_weight)
    cumulative = 0
    
    for model in available_models:
        cumulative += model["weight"]
        if r <= cumulative:
            print(f"Selected {model['name']} (tokens: {estimated_tokens})")
            return model["name"]
    
    return available_models[0]["name"]

# Helper function to create Groq client
async def create_groq_client(temperature: float = 0.7, estimated_tokens: int = 500):
    model_name = await select_available_model(estimated_tokens)
    
    # Apply rate limiting for this model
    await _groq_rate_limiter.acquire(model_name)
    
    return OpenAIChatCompletionClient(
        model=model_name,
        base_url="https://api.groq.com/openai/v1",
        api_key=os.getenv("GROQ_API_KEY"),
        model_info={
            "vision": False,
            "function_calling": True,
            "json_output": True,
            "structured_output": True,
            "family": "unknown",
        },
        temperature=temperature
    )

class Agent(RoutedAgent):

    system_message = """
    You are a creative entrepreneur. Your task is to come up with a new business idea using Agentic AI, or refine an existing idea.
    Your personal interests are in these sectors: Healthcare, Education.
    You are drawn to ideas that involve disruption.
    You are less interested in ideas that are purely automation.
    You are optimistic, adventurous and have risk appetite. You are imaginative - sometimes too much so.
    Your weaknesses: you're not patient, and can be impulsive.
    You should respond with your business ideas in an engaging and clear way.
    Keep responses concise and under 500 words.
    """

    CHANCES_THAT_I_BOUNCE_IDEA_OFF_ANOTHER = 0.2  # Further reduced

    def __init__(self, name) -> None:
        super().__init__(name)
        # Check for API key
        if not os.getenv("GROQ_API_KEY"):
            raise ValueError("GROQ_API_KEY not found in environment variables")
        
        # Initialize but don't create client yet - will create on demand
        self.model_client = None
        self._delegate = None

    async def ensure_delegate(self, estimated_tokens: int = 500):
        if self._delegate is None:
            self.model_client = await create_groq_client(temperature=0.8, estimated_tokens=estimated_tokens)
            self._delegate = AssistantAgent(self.id.key, model_client=self.model_client, system_message=self.system_message)

    @message_handler
    async def handle_message(self, message: messages.Message, ctx: MessageContext) -> messages.Message:
        print(f"{self.id.type}: Received message")
        
        # Estimate tokens for this message
        estimated_tokens = estimate_tokens(message.content) + 500  # Add buffer for response
        
        # Ensure delegate is created
        await self.ensure_delegate(estimated_tokens=estimated_tokens)
        
        text_message = TextMessage(content=message.content, source="user")
        response = await self._delegate.on_messages([text_message], ctx.cancellation_token)
        idea = response.chat_message.content
        
        if random.random() < self.CHANCES_THAT_I_BOUNCE_IDEA_OFF_ANOTHER:
            recipient = messages.find_recipient()
            if recipient:
                message = f"Please refine this business idea: {idea[:500]}..."  # Truncate to save tokens
                
                # Create new client for this message
                temp_client = await create_groq_client(temperature=0.8, estimated_tokens=500)
                
                response = await self.send_message(messages.Message(content=message), recipient)
                idea = response.content
                
        return messages.Message(content=idea)