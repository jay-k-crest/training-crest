# create_pinecone_index.py
import os
from pinecone import Pinecone, ServerlessSpec
from dotenv import load_dotenv

load_dotenv()

# Initialize Pinecone
pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
index_name = "debate-memory"

# Check if index exists
if index_name not in pc.list_indexes().names():
    print(f"Creating index: {index_name}")
    
    # FREE TIER - Use AWS us-east-1 (the current free tier region)
    pc.create_index(
        name=index_name,
        dimension=1024,
        metric="cosine",
        spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"  # This is the free tier region now
        )
    )
    print(f"✅ Index {index_name} created successfully!")
else:
    print(f"✅ Index {index_name} already exists")

# Describe index to verify
index_info = pc.describe_index(index_name)
print(f"\n📊 Index info: {index_info}")

# List all indexes
print("\n📊 Available indexes:")
for idx in pc.list_indexes().names():
    print(f"   - {idx}")