# LightRAG MCP Server
[![Lint](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/lint.yml/badge.svg)](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/lint.yml)
[![Tests](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/tests.yml/badge.svg)](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/tests.yml)
[![Docker](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/docker.yml/badge.svg)](https://github.com/a-earthperson/lightrag-mcp/actions/workflows/docker.yml)
[![Coverage](https://codecov.io/gh/a-earthperson/lightrag-mcp/branch/main/graph/badge.svg)](https://codecov.io/gh/a-earthperson/lightrag-mcp)
[![Docker Image](https://img.shields.io/badge/ghcr.io-lightrag--mcp-blue)](https://github.com/a-earthperson/lightrag-mcp/pkgs/container/lightrag-mcp)

MCP server for integrating LightRAG with AI tools. Provides a unified interface for interacting with LightRAG API through the MCP protocol.

## Description

LightRAG MCP Server is a bridge between LightRAG API and MCP-compatible clients. It allows using LightRAG (Retrieval-Augmented Generation) capabilities in various AI tools that support the MCP protocol.

### Key Features

- **Information Retrieval**: Execute semantic and keyword queries to documents
- **Document Management**: Upload, index, and track document status
- **Knowledge Graph Operations**: Manage entities and relationships in the knowledge graph
- **Monitoring**: Check LightRAG API status and document processing

## Installation

This server is designed to be used as an MCP server and should be installed in a virtual environment using uv, not as a system-wide package.

### Development Installation

```bash
# Create a virtual environment
uv venv --python 3.11

# Install the package in development mode
uv pip install -e .
```

## Requirements

- Python 3.11+
- Running LightRAG API server

## Docker and Docker Compose

This repo ships a `Dockerfile` for the MCP server and a `docker-compose.yml` that runs both LightRAG and the MCP server together.

### Quick start (Docker Compose)

```bash
docker compose up -d --build
docker compose ps
```

MCP endpoint: `http://localhost:8000/`  
LightRAG API: `http://localhost:9621/`

## Usage

LightRAG MCP server supports two MCP transport modes:
- **stdio (default)**: run through an MCP client configuration file (`mcp-config.json`)
- **streamable-http**: run as a standalone HTTP server for remote MCP clients

### Command Line Options

LightRAG API connection:

- `--host`: LightRAG API host (default: localhost)
- `--port`: LightRAG API port (default: 9621)
- `--api-key`: LightRAG API key (optional)

MCP transport:

- `--mcp-transport`: MCP transport (`stdio` or `streamable-http`, default: stdio)
- `--mcp-http-host`: MCP HTTP host (default: 127.0.0.1)
- `--mcp-http-port`: MCP HTTP port (default: 8000)
- `--mcp-http-path`: MCP HTTP base/mount path (default: /)
- `--mcp-http-stateless`: Enable stateless HTTP mode (new session per request)
- `--mcp-http-json-response`: Return JSON responses instead of SSE for HTTP

### Integration with LightRAG API

The MCP server requires a running LightRAG API server. Start it as follows:

```bash
# Create virtual environment
uv venv --python 3.11

# Install dependencies
uv pip install -r LightRAG/lightrag/api/requirements.txt

# Start LightRAG API
uv run LightRAG/lightrag/api/lightrag_server.py --host localhost --port 9621 --working-dir ./rag_storage --input-dir ./input --llm-binding openai --embedding-binding openai --log-level DEBUG
```

### Setting up as MCP server (stdio)

To set up LightRAG MCP as an MCP server, add the following configuration to your MCP client configuration file (e.g., `mcp-config.json`):

#### Using uvenv (uvx):

```json
{
  "mcpServers": {
    "lightrag-mcp": {
      "command": "uvx",
      "args": [
        "lightrag_mcp",
        "--host",
        "localhost",
        "--port",
        "9621",
        "--api-key",
        "your_api_key"
      ]
    }
  }
}
```

#### Development

```json
{
  "mcpServers": {
    "lightrag-mcp": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/lightrag_mcp",
        "run",
        "src/lightrag_mcp/main.py",
        "--host",
        "localhost",
        "--port",
        "9621",
        "--api-key",
        "your_api_key"
      ]
    }
  }
}
```

Replace `/path/to/lightrag_mcp` with the actual path to your lightrag-mcp directory.

### Running over Streamable HTTP (standalone server)

Use this when you need remote access or want to host the MCP server behind HTTP infrastructure:

```bash
uv run src/lightrag_mcp/main.py \
  --mcp-transport streamable-http \
  --mcp-http-host 0.0.0.0 \
  --mcp-http-port 8000 \
  --mcp-http-path /mcp \
  --host localhost \
  --port 9621 \
  --api-key your_api_key
```

MCP clients should connect to: `http://localhost:8000/mcp`

### Docker runtime configuration

Provide secrets like `LIGHTRAG_API_KEY` at runtime (not in the image):

```bash
docker build -t lightrag-mcp:local .
docker run --rm -it --env-file docker/mcp-example.env lightrag-mcp:local
```

## Available MCP Tools

### Document Queries
- `query_document`: Execute a query to documents through LightRAG API

### Document Management
- `insert_document`: Add text directly to LightRAG storage
- `upload_document`: Upload document from file to the /input directory
- `insert_file`: Add document from file directly to storage
- `insert_batch`: Add batch of documents from directory
- `scan_for_new_documents`: Start scanning the /input directory for new documents
- `get_documents`: Get list of all uploaded documents
- `get_pipeline_status`: Get status of document processing in pipeline

### Knowledge Graph Operations
- `get_graph_labels`: Get labels (node and relationship types) from knowledge graph
- `create_entities`: Create multiple entities in knowledge graph
- `edit_entities`: Edit multiple existing entities in knowledge graph
- `delete_by_entities`: Delete multiple entities from knowledge graph by name
- `delete_by_doc_ids`: Delete all entities and relationships associated with multiple documents
- `create_relations`: Create multiple relationships between entities in knowledge graph
- `edit_relations`: Edit multiple relationships between entities in knowledge graph
- `merge_entities`: Merge multiple entities into one with relationship migration

### Monitoring
- `check_lightrag_health`: Check LightRAG API status

## Development

### Installing development dependencies

```bash
uv pip install -e ".[dev]"
```

### Running linters

```bash
ruff check src/
mypy src/
```

## License

MIT
