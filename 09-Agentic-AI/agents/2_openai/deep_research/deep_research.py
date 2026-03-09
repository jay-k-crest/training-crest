import gradio as gr
from dotenv import load_dotenv
from research_manager import ResearchManager
from openai import AsyncOpenAI
from agents import set_default_openai_client, set_tracing_disabled, set_tracing_export_api_key
import os

load_dotenv(override=True)

# Setup Groq client
custom_client = AsyncOpenAI(
    api_key=os.environ.get("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)
set_default_openai_client(custom_client)

# Setup tracing (uses OpenAI API key)
set_tracing_disabled(False)
set_tracing_export_api_key(os.environ.get("OPENAI_API_KEY"))


async def run(query: str):
    async for chunk in ResearchManager().run(query):
        yield chunk


# Custom CSS for better styling
custom_css = """
:root {
    --primary-color: #4361ee;
    --secondary-color: #3a0ca3;
    --background: #f8f9fa;
    --text-color: #212529;
}

.dark {
    --primary-color: #4895ef;
    --secondary-color: #4cc9f0;
    --background: #212529;
    --text-color: #f8f9fa;
}

.gradio-container {
    background-color: var(--background) !important;
    color: var(--text-color) !important;
}

h1 {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 3rem !important;
    font-weight: 700 !important;
    margin-bottom: 1rem !important;
    text-align: center;
}

.subtitle {
    text-align: center;
    color: #6c757d;
    margin-bottom: 2rem;
    font-size: 1.2rem;
}

.gr-box {
    border-radius: 15px !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1) !important;
    border: 1px solid #dee2e6 !important;
    background-color: white !important;
}

.dark .gr-box {
    background-color: #2b3035 !important;
    border-color: #495057 !important;
}

.gr-button {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color)) !important;
    color: white !important;
    border: none !important;
    border-radius: 8px !important;
    padding: 10px 20px !important;
    font-weight: 600 !important;
    transition: transform 0.2s !important;
}

.gr-button:hover {
    transform: scale(1.02) !important;
    box-shadow: 0 4px 12px rgba(67, 97, 238, 0.3) !important;
}

.gr-textbox input, .gr-textbox textarea {
    border-radius: 8px !important;
    border: 2px solid #e9ecef !important;
    padding: 12px !important;
    font-size: 1rem !important;
}

.gr-textbox input:focus, .gr-textbox textarea:focus {
    border-color: var(--primary-color) !important;
    box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1) !important;
}

.gr-markdown {
    padding: 20px !important;
    border-radius: 12px !important;
    background-color: #f8f9fa !important;
    border: 1px solid #dee2e6 !important;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
    line-height: 1.6 !important;
}

.dark .gr-markdown {
    background-color: #2b3035 !important;
    border-color: #495057 !important;
}

/* Loading animation */
@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
}

.loading {
    animation: pulse 1.5s ease-in-out infinite;
    color: var(--primary-color);
    font-weight: 600;
}

/* Status messages */
.status {
    padding: 10px;
    border-radius: 8px;
    margin: 10px 0;
    background-color: #e7f3ff;
    border-left: 4px solid var(--primary-color);
    color: #004085;
}

.dark .status {
    background-color: #1e3a5f;
    color: #b8daff;
}

/* Report styling */
.report h1 {
    font-size: 2.5rem !important;
    margin-top: 0 !important;
}

.report h2 {
    color: var(--primary-color);
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 8px;
    margin-top: 24px;
}

.report pre {
    background-color: #1e1e1e !important;
    color: #d4d4d4 !important;
    padding: 16px !important;
    border-radius: 8px !important;
    overflow-x: auto !important;
}

.report code {
    background-color: #f1f3f5;
    padding: 2px 4px;
    border-radius: 4px;
    font-size: 0.9em;
}

.dark .report code {
    background-color: #2d2d2d;
    color: #e9ecef;
}
"""

with gr.Blocks(theme=gr.themes.Soft(), css=custom_css) as ui:
    gr.Markdown("# 🔍 Deep Research Agent")
    gr.Markdown("### AI-powered multi-agent research system")
    gr.Markdown("---")
    
    with gr.Row():
        with gr.Column(scale=1):
            gr.Markdown("""
            ### 📋 How it works
            1. **Planner** creates search strategy
            2. **Search agent** gathers information
            3. **Writer** compiles comprehensive report
            4. **Email agent** sends results
            
            ### ⚡ Features
            - Multi-agent collaboration
            - Web search integration
            - Detailed markdown reports
            - Email delivery
            """)
        
        with gr.Column(scale=2):
            query_textbox = gr.Textbox(
                label="📝 Research Topic",
                placeholder="e.g., Latest developments in quantum computing, AI regulations 2025, etc.",
                lines=2
            )
            
            with gr.Row():
                run_button = gr.Button("🚀 Start Research", variant="primary", size="lg")
                clear_button = gr.Button("🗑️ Clear", variant="secondary")
            
            status_box = gr.Markdown(
                value="Ready to research!",
                elem_classes=["status"]
            )
    
    gr.Markdown("---")
    gr.Markdown("### 📄 Research Report")
    
    report = gr.Markdown(
        label="Report",
        elem_classes=["report"],
        height=600
    )
    
    # Event handlers
    async def run_with_status(query):
        if not query:
            yield "⚠️ Please enter a research topic", ""
            return
        
        # Start with status and empty report
        yield "🔍 Starting research...", ""
        
        async for chunk in run(query):
            if chunk.startswith("View trace:"):
                yield f"📊 {chunk}", ""
            elif chunk in ["Searches planned, starting to search...", 
                        "Searches complete, writing report...",
                        "Report written, sending email...",
                        "Email sent, research complete"]:
                yield f"⏳ {chunk}", ""
            elif "http" in chunk and "trace" in chunk:
                yield f"🔗 {chunk}", ""
            else:
                # This is the final report
                yield "✅ Research complete!", chunk
                return  # Stop after yielding the report
    
    run_button.click(
        fn=run_with_status, 
        inputs=query_textbox, 
        outputs=[status_box, report]
    )
    
    query_textbox.submit(
        fn=run_with_status, 
        inputs=query_textbox, 
        outputs=[status_box, report]
    )
    
    clear_button.click(
        fn=lambda: ("Ready to research!", ""),
        outputs=[status_box, report]
    )

if __name__ == "__main__":
    ui.launch(
        inbrowser=True,
        share=False,
        server_name="127.0.0.1",
        server_port=7860
    )