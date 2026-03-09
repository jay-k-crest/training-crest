#!/usr/bin/env python
import sys
import warnings
import logging
from datetime import datetime

from financial_researcher.crew import FinancialResearcher

warnings.filterwarnings("ignore", category=SyntaxWarning, module="pysbd")

warnings.filterwarnings("ignore", module="litellm")
warnings.filterwarnings("ignore", message="Missing dependency")
logging.getLogger("litellm").setLevel(logging.ERROR)

def run():
    """Run the Financial researcher crew"""
    
    inputs = {
        'company':'Tesla'
    }
    
    result = FinancialResearcher().crew().kickoff(inputs=inputs)
    print(result.raw)
    
    if __name__ == '__main__':
        run()
    
    
    

