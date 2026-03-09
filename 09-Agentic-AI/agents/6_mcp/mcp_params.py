import os
import sys
import shutil
from dotenv import load_dotenv

load_dotenv(override=True)

# Find npx on Windows
npx_path = shutil.which("npx") or shutil.which("npx.cmd") or "npx"

brave_env = {"BRAVE_API_KEY": os.getenv("BRAVE_API_KEY", "")}
polygon_api_key = os.getenv("POLYGON_API_KEY")
polygon_plan = os.getenv("POLYGON_PLAN", "free")

is_paid_polygon = polygon_plan == "paid"
is_realtime_polygon = polygon_plan == "realtime"

# Market MCP server
if is_paid_polygon or is_realtime_polygon:
    market_mcp = {
        "command": "uvx",
        "args": ["--from", "git+https://github.com/polygon-io/mcp_polygon@v0.1.0", "mcp_polygon"],
        "env": {"POLYGON_API_KEY": polygon_api_key},
    }
else:
    market_mcp = {"command": sys.executable, "args": ["market_server.py"]}

# Trader MCP servers
trader_mcp_server_params = [
    {"command": sys.executable, "args": ["accounts_server.py"]},
    {"command": sys.executable, "args": ["push_server.py"]},
    market_mcp,
]

# Researcher MCP servers
def researcher_mcp_server_params(name: str):
    return [
        {"command": sys.executable, "args": ["-m", "mcp_server_fetch"]},
        {
            "command": npx_path,
            "args": ["-y", "@modelcontextprotocol/server-brave-search"],
            "env": brave_env,
        },
        {
            "command": npx_path,
            "args": ["-y", "mcp-memory-libsql"],
            "env": {"LIBSQL_URL": f"file:./memory/{name}.db"},
        },
    ]