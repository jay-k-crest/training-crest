# webhook_server.py - Fixed with trace import
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import uvicorn
import os
from dotenv import load_dotenv
import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content
from agents import Agent, Runner, function_tool, set_default_openai_client, set_tracing_disabled, set_tracing_export_api_key, trace  # Added trace here!
from openai import AsyncOpenAI

load_dotenv()

# YOUR EXACT SETUP from notebook cells
custom_client = AsyncOpenAI(
    api_key=os.environ.get("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)
set_default_openai_client(custom_client)

# Add tracing setup from your notebook (cells 3 and 7)
set_tracing_disabled(False)

set_tracing_export_api_key(os.environ.get("OPENAI_API_KEY"))  # For traces

app = FastAPI()

# YOUR MODEL NAME from cell 49
model_name = "llama-3.1-8b-instant"

# Create reply agent using YOUR model
reply_agent = Agent(
    name="Reply Agent",
    instructions="""You are a helpful sales agent from ComplAI responding to email replies.
    You write professional, helpful responses about SOC2 compliance and AI-powered audit tools.
    Keep responses concise but friendly.""",
    model=model_name
)

@app.post("/webhook/email-reply")
async def handle_reply(request: Request):
    try:
        set_tracing_export_api_key(os.environ.get("OPENAI_API_KEY"))
        set_tracing_disabled(False)
        print(os.environ.get("OPENAI_API_KEY")) 
        data = await request.json()
        print(f"Received webhook: {data}")
        
        for event in data:
            if event.get('event') != 'reply':  
                continue
                
            reply_body = event.get('text') or event.get('html') or "No content"
            sender = event.get('from') or event.get('email')
            
            print("="*50)
            if not sender or not reply_body:
                continue
                
            print(f"Reply from {sender}: {reply_body[:100]}...")
            
            # Generate response using YOUR Groq model (with tracing!)
            with trace("Auto-Reply"):
                response = await Runner.run(
                    reply_agent, 
                    f"Customer replied to our sales email: {reply_body}\n\nWrite a helpful response:"
                )
            
            # Send reply via SendGrid
            sg = sendgrid.SendGridAPIClient(api_key=os.environ.get('SENDGRID_API_KEY'))
            from_email = Email("jay.k@crestskillserve.com")
            to_email = To(sender)
            content = Content("text/plain", response.final_output)
            mail = Mail(from_email, to_email, "Re: ComplAI - Thanks for your reply", content).get()
            
            sg_response = sg.client.mail.send.post(request_body=mail)
            print(f"Reply sent with status: {sg_response.status_code}")
        
        return {"status": "ok"}
    
    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse({"status": "error", "message": str(e)}, status_code=500)

@app.get("/health")
async def health():
    return {"status": "alive", "model": model_name}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)