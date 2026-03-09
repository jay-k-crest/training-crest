from autogen_ext.runtimes.grpc import GrpcWorkerAgentRuntimeHost
from agent import Agent
from creator import Creator
from autogen_ext.runtimes.grpc import GrpcWorkerAgentRuntime
from autogen_core import AgentId
import messages
import asyncio
import time
import random

# Further reduced agent count to 6
HOW_MANY_AGENTS = 6
# Increased delay to 6 seconds
DELAY_BETWEEN_REQUESTS = 6.0
# Reduced concurrency to 3
MAX_CONCURRENT = 3

async def create_and_message(worker, creator_id, i: int, semaphore):
    async with semaphore:
        try:
            print(f"Starting agent {i} creation at {time.strftime('%H:%M:%S')}...")
            
            # Add jitter to avoid thundering herd
            jitter = random.uniform(0, 2.0)
            await asyncio.sleep(jitter)
            
            result = await worker.send_message(messages.Message(content=f"agent{i}.py"), creator_id)
            
            # Ensure we can write the file with proper encoding
            content = result.content
            if isinstance(content, str):
                content = content.encode('ascii', 'ignore').decode('ascii')
            
            with open(f"idea{i}.md", "w", encoding="utf-8") as f:
                f.write(content)
            
            print(f"Completed agent {i} at {time.strftime('%H:%M:%S')}")
            
            # Add delay to respect rate limit
            await asyncio.sleep(DELAY_BETWEEN_REQUESTS)
            
        except Exception as e:
            print(f"Failed to run worker {i} due to exception: {e}")
            # Wait extra on error
            await asyncio.sleep(DELAY_BETWEEN_REQUESTS * 2)

async def main():
    print(f"Starting agent creation with {HOW_MANY_AGENTS} agents")
    print(f"Delay between requests: {DELAY_BETWEEN_REQUESTS}s")
    print(f"Max concurrent: {MAX_CONCURRENT}")
    
    host = GrpcWorkerAgentRuntimeHost(address="localhost:50051")
    host.start() 
    
    worker = GrpcWorkerAgentRuntime(host_address="localhost:50051")
    await worker.start()
    
    result = await Creator.register(worker, "Creator", lambda: Creator("Creator"))
    creator_id = AgentId("Creator", "default")
    
    # Create a semaphore to limit concurrent requests
    semaphore = asyncio.Semaphore(MAX_CONCURRENT)
    
    # Stagger the start of coroutines
    coroutines = []
    for i in range(1, HOW_MANY_AGENTS + 1):
        coroutines.append(create_and_message(worker, creator_id, i, semaphore))
        # Stagger the starts
        await asyncio.sleep(1.0)
    
    # Use gather with return_exceptions=True
    results = await asyncio.gather(*coroutines, return_exceptions=True)
    
    # Check for failures
    successful = 0
    failed = 0
    for i, result in enumerate(results, 1):
        if isinstance(result, Exception):
            print(f"Agent {i} failed: {result}")
            failed += 1
        else:
            successful += 1
    
    print(f"\nSummary: {successful} agents created successfully, {failed} failed")
    
    # Wait a bit before shutting down
    await asyncio.sleep(5)
    
    try:
        await worker.stop()
        await host.stop()
    except Exception as e:
        print(e)

if __name__ == "__main__":
    asyncio.run(main())