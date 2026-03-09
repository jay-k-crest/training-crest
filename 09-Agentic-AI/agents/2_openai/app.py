import asyncio
from agents import Agent, Runner, trace, set_default_openai_client
from openai import AsyncOpenAI

# Create a custom OpenAI client for Groq
custom_client = AsyncOpenAI(
    api_key=os.environ.get("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)

# Set it as the default client
set_default_openai_client(custom_client)

# Now try with a Groq model
agent = Agent(
    name="Jokester", 
    instructions="You are a joke teller", 
    model="llama3-70b-8192"  # Use an actual Groq model
)

async def main():
    with trace("Telling a joke"):
        result = await Runner.run(agent, "Tell a joke about Autonomous AI Agents")
        print(result.final_output)

asyncio.run(main())