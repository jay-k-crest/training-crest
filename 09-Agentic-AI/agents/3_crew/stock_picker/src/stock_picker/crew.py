from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai_tools import SerperDevTool
from pydantic import BaseModel, Field
from typing import List
from .tools.push_tool import PushNotificationTool
from crewai.memory import LongTermMemory, ShortTermMemory, EntityMemory
from crewai.memory.storage.rag_storage import RAGStorage
from crewai.memory.storage.ltm_sqlite_storage import LTMSQLiteStorage
import os


class TrendingCompany(BaseModel):
    """ A company that is in the news and attracting attention """
    name: str = Field(description="Company name")
    ticker: str = Field(description="Stock ticker symbol")
    reason: str = Field(description="Reason this company is trending in the news")

class TrendingCompanyList(BaseModel):
    """ List of multiple trending companies that are in the news """
    companies: List[TrendingCompany] = Field(description="List of companies trending in the news")

class TrendingCompanyResearch(BaseModel):
    """ Detailed research on a company """
    name: str = Field(description="Company name")
    market_position: str = Field(description="Current market position and competitive analysis")
    future_outlook: str = Field(description="Future outlook and growth prospects")
    investment_potential: str = Field(description="Investment potential and suitability for investment")

class TrendingCompanyResearchList(BaseModel):
    """ A list of detailed research on all the companies """
    research_list: List[TrendingCompanyResearch] = Field(description="Comprehensive research on all trending companies")


@CrewBase
class StockPicker():
    """StockPicker crew"""

    agents_config = 'config/agents.yaml'
    tasks_config = 'config/tasks.yaml'

    @agent
    def trending_company_finder(self) -> Agent:
        return Agent(config=self.agents_config['trending_company_finder'], 
                     memory=True,
                     tools=[SerperDevTool(n_results=3)],
                     max_tokens=1500, 
                     temperature=0.3,
                     tool_instructions="The search tool only accepts one parameter: 'search_query'. Do not include any other parameters like 'type' or 'num'."
                     )
    
    @agent
    def financial_researcher(self) -> Agent:
        return Agent(config=self.agents_config['financial_researcher'], 
                     tools=[SerperDevTool(n_results=3)],
                     max_tokens=1500, 
                     temperature=0.3,
                     tool_instructions="The search tool only accepts one parameter: 'search_query'. Do not include any other parameters like 'type' or 'num'."
        )

    @agent
    def stock_picker(self) -> Agent:
        return Agent(config=self.agents_config['stock_picker'], 
                     tools=[PushNotificationTool()],
                     max_tokens=1500, 
                     temperature=0.3,
                     memory=True
                     )
    
    @task
    def find_trending_companies(self) -> Task:
        return Task(
            config=self.tasks_config['find_trending_companies'],
            output_pydantic=TrendingCompanyList,
        )

    @task
    def research_trending_companies(self) -> Task:
        return Task(
            config=self.tasks_config['research_trending_companies'],
            output_pydantic=TrendingCompanyResearchList,
        )

    @task
    def pick_best_company(self) -> Task:
        return Task(
            config=self.tasks_config['pick_best_company'],
        )
    
    @crew
    def crew(self) -> Crew:
        """Creates the StockPicker crew"""

        manager = Agent(
            config=self.agents_config['manager'],
            allow_delegation=True
        )
        
        # Free embedding config using Cohere (you already have the API key)
        free_embedder_config = {
            "provider": "cohere",
            "config": {
                "model": "embed-english-v3.0",  # Cohere's embedding model
                "api_key": "your api key "  # Your Cohere API key from .env
            }
        }
            
        return Crew(
            agents=self.agents,
            tasks=self.tasks, 
            process=Process.hierarchical,
            verbose=True,
            manager_agent=manager,
            memory=True,
            tracing=True,
            # Long-term memory for persistent storage across sessions
            long_term_memory = LongTermMemory(
                storage=LTMSQLiteStorage(
                    db_path="./memory/long_term_memory_storage.db"
                )
            ),
            # Short-term memory for current context using RAG with Cohere embeddings (FREE)
            short_term_memory = ShortTermMemory(
                storage = RAGStorage(
                        embedder_config=free_embedder_config,  # Using Cohere (free tier)
                        type="short_term",
                        path="./memory/"
                    )
                ),
            # Entity memory for tracking key information about entities with Cohere embeddings (FREE)
            entity_memory = EntityMemory(
                storage=RAGStorage(
                    embedder_config=free_embedder_config,  # Using Cohere (free tier)
                    type="entity",  # Changed from "short_term" to "entity" for clarity
                    path="./memory/"
                )
            ),
        )