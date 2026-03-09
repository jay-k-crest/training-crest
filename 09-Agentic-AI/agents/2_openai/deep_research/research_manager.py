from agents import Runner, trace, gen_trace_id
from search_agent import search_agent
from planner_agent import planner_agent, WebSearchItem, WebSearchPlan
from writer_agent import writer_agent, ReportData
from email_agent import email_agent
import asyncio
import json
import re

class ResearchManager:

    async def run(self, query: str):
        """ Run the deep research process, yielding the status updates and the final report"""
        trace_id = gen_trace_id()
        with trace("Research trace", trace_id=trace_id):
            print(f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}")
            yield f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}"
            print("Starting research...")
            search_plan = await self.plan_searches(query)
            yield "Searches planned, starting to search..."
            search_results = await self.perform_searches(search_plan)
            yield "Searches complete, writing report..."
            report = await self.write_report(query, search_results)
            yield "Report written, sending email..."
            await self.send_email(report)
            yield "Email sent, research complete"
            yield report.markdown_report


    async def plan_searches(self, query: str) -> WebSearchPlan:
        """ Plan the searches to perform for the query """
        print("Planning searches...")
        result = await Runner.run(
            planner_agent,
            f"Query: {query}",
        )
        
        # Clean and parse JSON
        output = result.final_output.strip()
        # Remove markdown code blocks
        if "```json" in output:
            output = output.split("```json")[1].split("```")[0]
        elif "```" in output:
            output = output.split("```")[1].split("```")[0]
        
        # Find JSON if still not clean
        json_match = re.search(r'\{.*\}', output, re.DOTALL)
        if json_match:
            output = json_match.group()
        
        data = json.loads(output)
        search_plan = WebSearchPlan(**data)
        print(f"Will perform {len(search_plan.searches)} searches")
        return search_plan

    async def perform_searches(self, search_plan: WebSearchPlan) -> list[str]:
        """ Perform the searches to perform for the query """
        print("Searching...")
        num_completed = 0
        tasks = [asyncio.create_task(self.search(item)) for item in search_plan.searches]
        results = []
        
        for task in asyncio.as_completed(tasks):
            # Small delay between searches (30K TPM = ~500 tokens/sec, 2 sec is fine)
            if num_completed > 0:
                await asyncio.sleep(2)
            
            result = await task
            if result is not None:
                results.append(result)
            num_completed += 1
            print(f"Searching... {num_completed}/{len(tasks)} completed")
        
        print("Finished searching")
        return results

    async def search(self, item: WebSearchItem) -> str | None:
        """ Perform a search for the query """
        input = f"Search term: {item.query}\nReason for searching: {item.reason}"
        try:
            result = await Runner.run(
                search_agent,
                input,
            )
            return str(result.final_output)
        except Exception as e:
            print(f"Search error: {e}")
            return None

    async def write_report(self, query: str, search_results: list[str]) -> ReportData:
        """ Write the report for the query """
        print("Thinking about report...")
        input = f"Original query: {query}\nSummarized search results: {search_results}"
        result = await Runner.run(
            writer_agent,
            input,
        )

        # Clean and parse JSON
        output = result.final_output.strip()
        print(f"Raw output preview: {output[:200]}...")
        
        # Remove markdown code blocks
        if "```json" in output:
            output = output.split("```json")[1].split("```")[0]
        elif "```" in output:
            output = output.split("```")[1].split("```")[0]
        
        # Find JSON between curly braces
        json_match = re.search(r'(\{.*\})', output, re.DOTALL)
        if json_match:
            output = json_match.group(1)
        
        # Clean only problematic control characters, preserve newlines
        output = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]', '', output)
        
        # Try to parse
        try:
            data = json.loads(output)
        except json.JSONDecodeError as e:
            print(f"JSON parse error: {e}")
            print(f"Problematic output: {output[:500]}")
            
            # More aggressive cleaning as fallback
            # Replace any remaining problematic sequences
            output = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', output)
            # Fix escaped quotes if needed
            output = output.replace('\\"', '"')
            # Try again
            data = json.loads(output)
        
        report = ReportData(**data)
        print("Finished writing report")
        return report

    async def send_email(self, report: ReportData) -> None:
        print("Writing email...")
        result = await Runner.run(
            email_agent,
            report.markdown_report,
        )
        print("Email sent")
        return report