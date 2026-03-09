from autogen_core import MessageContext, RoutedAgent, message_handler
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
from autogen_ext.models.openai import OpenAIChatCompletionClient
import messages
from autogen_core import TRACE_LOGGER_NAME
import importlib
import logging
from autogen_core import AgentId
from dotenv import load_dotenv
import os
import asyncio
from datetime import datetime, timedelta
import random

load_dotenv(override=True)

logging.basicConfig(level=logging.WARNING)
logger = logging.getLogger(TRACE_LOGGER_NAME)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)

# Model configurations - EXCLUDING moonshotai
MODELS = [
    {
        "name": "llama-3.3-70b-versatile",
        "rpm": 30,
        "tpm": 12000,
        "weight": 2.0,
        "requests_per_second": 0.5
    },
    {
        "name": "meta-llama/llama-4-scout-17b-16e-instruct",
        "rpm": 30,
        "tpm": 30000,
        "weight": 5.0,
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

# Token budget calculator
class TokenBudget:
    def __init__(self):
        self.model_usage = {model["name"]: {"tokens": 0, "reset_time": datetime.now()} for model in MODELS}
        self.lock = asyncio.Lock()
    
    async def can_use_model(self, model_name: str, estimated_tokens: int = 1000):
        async with self.lock:
            model_config = next((m for m in MODELS if m["name"] == model_name), None)
            if not model_config:
                return False
            
            now = datetime.now()
            usage = self.model_usage[model_name]
            
            if now - usage["reset_time"] > timedelta(minutes=1):
                usage["tokens"] = 0
                usage["reset_time"] = now
            
            # Leave 30% buffer for code generation
            safe_limit = model_config["tpm"] * 0.7
            
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
            
            self.model_requests[model_name] = [
                req_time for req_time in self.model_requests[model_name]
                if now - req_time < timedelta(minutes=1)
            ]
            
            # Leave 20% buffer on RPM
            safe_rpm = int(model_config["rpm"] * 0.8)
            
            if len(self.model_requests[model_name]) >= safe_rpm:
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

# Helper function to estimate tokens
def estimate_tokens(text: str) -> int:
    """Rough estimation for code: 1 token ≈ 3 characters"""
    return len(text) // 3

# Helper function to select model based on availability
async def select_available_model(estimated_tokens: int = 1000):
    available_models = []
    for model in MODELS:
        if await _token_budget.can_use_model(model["name"], estimated_tokens):
            available_models.append(model)
    
    if not available_models:
        print("No models available for code generation, waiting...")
        await asyncio.sleep(10)  # Wait longer for code generation
        return await select_available_model(estimated_tokens)
    
    # Prefer high TPM models for code generation
    high_tpm_models = [m for m in available_models if m["tpm"] >= 20000]
    if high_tpm_models:
        selected = random.choice(high_tpm_models)
        print(f"Selected high-TPM model for code: {selected['name']}")
        return selected["name"]
    
    total_weight = sum(model["weight"] for model in available_models)
    r = random.uniform(0, total_weight)
    cumulative = 0
    
    for model in available_models:
        cumulative += model["weight"]
        if r <= cumulative:
            print(f"Selected {model['name']} for code (tokens: {estimated_tokens})")
            return model["name"]
    
    return available_models[0]["name"]

# Helper function to create Groq client
async def create_groq_client(temperature: float = 1.0, estimated_tokens: int = 1000):
    model_name = await select_available_model(estimated_tokens)
    
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

class Creator(RoutedAgent):

    system_message = """
You are an Agent that creates new AI Agents by modifying a template.
You MUST follow these EXACT requirements:
1. The class MUST be named 'Agent' and inherit from 'RoutedAgent'
2. The __init__ method MUST take only a 'name' parameter and call super().__init__(name)
3. The class MUST have a 'system_message' class variable (not inside __init__)
4. The class MUST have a 'CHANCES_THAT_I_BOUNCE_IDEA_OFF_ANOTHER' class variable (0.2-0.5)
5. The handle_message method MUST have signature: async def handle_message(self, message: messages.Message, ctx: MessageContext) -> messages.Message
6. You MUST use the existing imports from the template - don't change them
7. You MUST create an AssistantAgent delegate in __init__ using create_groq_client helper
8. ONLY change the system_message content to make each agent unique

Here is the EXACT structure you must follow (only change the system_message):

from autogen_core import MessageContext, RoutedAgent, message_handler
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
import messages
import random
import asyncio
from dotenv import load_dotenv
import os

load_dotenv(override=True)

class Agent(RoutedAgent):
    system_message = "YOUR UNIQUE SYSTEM MESSAGE HERE"
    CHANCES_THAT_I_BOUNCE_IDEA_OFF_ANOTHER = 0.3

    def __init__(self, name) -> None:
        super().__init__(name)
        self.model_client = None
        self._delegate = None

    async def ensure_delegate(self):
        if self._delegate is None:
            from agent import create_groq_client
            self.model_client = await create_groq_client(temperature=0.8)
            self._delegate = AssistantAgent(self.id.key, model_client=self.model_client, system_message=self.system_message)

    @message_handler
    async def handle_message(self, message: messages.Message, ctx: MessageContext) -> messages.Message:
        await self.ensure_delegate()
        text_message = TextMessage(content=message.content, source="user")
        response = await self._delegate.on_messages([text_message], ctx.cancellation_token)
        return messages.Message(content=response.chat_message.content)

Respond ONLY with the Python code, no explanations, no markdown.
"""

    def __init__(self, name) -> None:
        super().__init__(name)
        if not os.getenv("GROQ_API_KEY"):
            raise ValueError("GROQ_API_KEY not found in environment variables")
        
        self.model_client = None
        self._delegate = None

    async def ensure_delegate(self, estimated_tokens: int = 2000):
        if self._delegate is None:
            self.model_client = await create_groq_client(temperature=1.0, estimated_tokens=estimated_tokens)
            self._delegate = AssistantAgent(self.id.key, model_client=self.model_client, system_message=self.system_message)

    def get_user_prompt(self):
        prompt = "Please generate a new Agent based strictly on this template. Keep it concise. \
            Respond only with the python code, no other text, and no markdown code blocks.\n\n\
            Here is the template:\n\n"
        with open("agent.py", "r", encoding="utf-8") as f:
            template = f.read()
        # Truncate template if too long
        if len(template) > 2000:
            template = template[:2000] + "\n    # ... (template truncated for brevity)"
        return prompt + template   
        
    @message_handler
    async def handle_my_message_type(self, message: messages.Message, ctx: MessageContext) -> messages.Message:
        filename = message.content
        agent_name = filename.split(".")[0]
        
        # Estimate tokens for code generation
        prompt = self.get_user_prompt()
        estimated_tokens = estimate_tokens(prompt) + 2000  # Add buffer for generated code
        
        # Ensure delegate is created
        await self.ensure_delegate(estimated_tokens=estimated_tokens)
        
        text_message = TextMessage(content=prompt, source="user")
        response = await self._delegate.on_messages([text_message], ctx.cancellation_token)
        
        code_content = response.chat_message.content
        if code_content.startswith('```python'):
          code_content = code_content.replace('```python', '', 1)
        if code_content.endswith('```'):
            code_content = code_content[:-3]
        code_content = code_content.strip()
        
        with open(filename, "w", encoding="utf-8") as f:
            f.write(code_content)
            
        print(f"** Creator has created python code for agent {agent_name} - about to register with Runtime")
        module = importlib.import_module(agent_name)
        await module.Agent.register(self.runtime, agent_name, lambda: module.Agent(agent_name))
        logger.info(f"** Agent {agent_name} is live")
        
        # Create a new client for this specific message
        temp_client = await create_groq_client(temperature=0.8, estimated_tokens=500)
        
        result = await self.send_message(messages.Message(content="Give me an idea"), AgentId(agent_name, "default"))
        return messages.Message(content=result.content)