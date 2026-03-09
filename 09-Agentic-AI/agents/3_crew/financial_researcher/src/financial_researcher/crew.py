import logging
import warnings

warnings.filterwarnings("ignore", module="litellm")
warnings.filterwarnings("ignore", message="Missing dependency")
logging.getLogger("litellm").setLevel(logging.ERROR)

from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai.agents.agent_builder.base_agent import BaseAgent
from typing import List
from crewai_tools import SerperDevTool




@CrewBase
class FinancialResearcher():
    """FinancialResearcher crew"""
    
    
    agents_config = 'config/agents.yaml'
    tasks_config = 'config/tasks.yaml'
    
    
    @agent
    def researcher(self) -> Agent:
        return Agent(
            config=self.agents_config['researcher'],
            verbose=True,
            tools=[SerperDevTool(n_results=3)],
            max_tokens=1500, 
            temperature=0.3,
            tool_instructions="The search tool only accepts one parameter: 'search_query'. Do not include any other parameters like 'type' or 'num'."
        )

    @agent
    def analyst(self) -> Agent:
        return Agent(
            config=self.agents_config['analyst'],
            verbose=True
        )
    
    @task
    def research_task(self) -> Task:
        return Task(
            config=self.tasks_config['research_task'],
            verbose=True
        )
    
    @task
    def analysis_task(self) -> Task:
        return Task(
            config=self.tasks_config['analysis_task'],
            verbose=True
        )
    
    @crew
    def crew(self) -> Crew:
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process = Process.sequential,
            verbose=True,
            tracing=True
        )