# src/financial_researcher/__init__.py
import warnings
import logging

# Suppress all LiteLLM warnings and logs
warnings.filterwarnings("ignore", module="litellm")
logging.getLogger("litellm").setLevel(logging.ERROR)

# Optionally suppress other noisy loggers
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)