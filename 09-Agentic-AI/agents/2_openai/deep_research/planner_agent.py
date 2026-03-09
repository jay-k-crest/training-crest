from pydantic import BaseModel, Field
from agents import Agent

HOW_MANY_SEARCHES = 3

INSTRUCTIONS = f"""Given a query, output {HOW_MANY_SEARCHES} search terms to best answer it.
For each search term, provide:
1. The search query
2. A brief reason why this search is important

Format as JSON with this structure:
{{
    "searches": [
        {{
            "query": "search term here",
            "reason": "reason here"
        }}
    ]
}}
Return ONLY the JSON, no other text."""

class WebSearchItem(BaseModel):
    reason: str = Field(description="Your reasoning for why this search is important to the query.")
    query: str = Field(description="The search term to use for the web search.")

class WebSearchPlan(BaseModel):
    searches: list[WebSearchItem] = Field(description="A list of web searches to perform to best answer the query.")

planner_agent = Agent(
    name="PlannerAgent",
    instructions=INSTRUCTIONS,
    model="openai/meta-llama/llama-4-scout-17b-16e-instruct",  # 30K TPM
    # output_type=WebSearchPlan,  # Commented out - manual parsing
)