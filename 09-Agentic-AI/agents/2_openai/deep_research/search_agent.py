from agents import Agent, function_tool
from tavily import TavilyClient
import os

@function_tool
async def web_search(query: str) -> str:
    """Search the web for current information using Tavily"""
    client = TavilyClient(api_key=os.environ.get("TAVILY_API_KEY"))
    try:
        response = client.search(
            query=query,
            search_depth="advanced"  # Use "basic" for faster/cheaper
        )
        
        # Format the results nicely
        results = response.get('results', [])
        if not results:
            return "No results found."
        
        formatted = "\n\n".join([
            f"**{r.get('title', 'No title')}**\n{r.get('content', 'No content')[:300]}..."
            for r in results[:3]  # Limit to top 3 results
        ])
        return formatted
    except Exception as e:
        return f"Search error: {str(e)}"

INSTRUCTIONS = """You are a research assistant. Given a search term, use the web_search tool to find information.
Then provide a ONE SENTENCE summary (max 15 words) of the key finding. Just the fact, no explanations."""

search_agent = Agent(
    name="Search agent",
    instructions=INSTRUCTIONS,
    tools=[web_search],
    model="openai/meta-llama/llama-4-scout-17b-16e-instruct",  # 30K TPM - much higher limit!
)