from pydantic import BaseModel, Field
from agents import Agent

INSTRUCTIONS = """You are a senior researcher. Based on the research provided, create a report.

Your response MUST be a valid JSON object with exactly these fields:
{
  "short_summary": "2-3 sentence summary",
  "markdown_report": "# Title\\n\\nFull report in markdown...",
  "follow_up_questions": ["Question 1", "Question 2"]
}

Return ONLY the JSON, no other text. The markdown_report should be at least 1000 words."""

class ReportData(BaseModel):
    short_summary: str = Field(description="A short 2-3 sentence summary of the findings.")
    markdown_report: str = Field(description="The final report")
    follow_up_questions: list[str] = Field(description="Suggested topics to research further")

writer_agent = Agent(
    name="WriterAgent",
    instructions=INSTRUCTIONS,
    model="openai/meta-llama/llama-4-scout-17b-16e-instruct",  # 30K TPM
    # output_type=ReportData,  # Commented out - manual parsing
)