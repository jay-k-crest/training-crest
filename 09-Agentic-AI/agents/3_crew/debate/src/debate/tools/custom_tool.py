from crewai.tools import BaseTool
from typing import Type
from pydantic import BaseModel, Field

class DebateArgumentToolInput(BaseModel):
    """Input schema for DebateArgumentTool."""
    argument: str = Field(..., description="The debate argument to analyze")
    side: str = Field(..., description="Which side this argument supports: 'propose' or 'oppose'")

class DebateArgumentTool(BaseTool):
    name: str = "Debate Argument Analyzer"
    description: str = (
        "Tool to analyze debate arguments for strength, logic, and persuasiveness"
    )
    args_schema: Type[BaseModel] = DebateArgumentToolInput

    def _run(self, argument: str, side: str) -> str:
        # Simple analysis based on length and keywords
        word_count = len(argument.split())
        has_evidence = any(word in argument.lower() for word in ['because', 'evidence', 'study', 'research', 'data'])
        has_logic = any(word in argument.lower() for word in ['therefore', 'thus', 'consequently', 'if', 'then'])
        
        strength = "weak"
        if word_count > 50 and has_evidence and has_logic:
            strength = "strong"
        elif word_count > 30 and (has_evidence or has_logic):
            strength = "moderate"
            
        return f"Argument analysis for {side} side: {strength} argument ({word_count} words, evidence: {has_evidence}, logic: {has_logic})"