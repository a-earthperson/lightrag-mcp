"""
Configuration module for LightRAG MCP server.
"""

import argparse
from dataclasses import dataclass
from typing import Literal

@dataclass(frozen=True)
class LightRAGSettings:
    """Settings for connecting to the LightRAG API server."""

    host: str = "localhost"
    port: int = 9621
    api_key: str = ""

    @property
    def base_url(self) -> str:
        return f"http://{self.host}:{self.port}"


@dataclass(frozen=True)
class MCPSettings:
    """Settings for MCP transport and HTTP server."""

    name: str = "LightRAG MCP Server"
    website_url: str | None = None
    host: str = "127.0.0.1"
    port: int = 8000
    mount_path: str = "/"
    sse_path: str = "/sse"
    message_path: str = "/messages/"
    streamable_http_path: str = "/mcp"
    json_response: bool = True
    stateless_http: bool = True
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "DEBUG"
    debug: bool = True

    @property
    def http_url(self) -> str:
        return f"http://{self.host}:{self.port}{self.mount_path}"


def _normalize_path(path: str) -> str:
    if not path.startswith("/"):
        return f"/{path}"
    return path


def parse_args():
    """Parse command line arguments for LightRAG MCP server."""
    # LightRAG API connection
    parser = argparse.ArgumentParser(description="LightRAG MCP Server")
    parser.add_argument(
        "--host",
        default=LightRAGSettings.host,
        help=f"LightRAG API host (default: {LightRAGSettings.host})",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=LightRAGSettings.port,
        help=f"LightRAG API port (default: {LightRAGSettings.port})",
    )
    parser.add_argument(
        "--api-key",
        default=LightRAGSettings.api_key,
        help="LightRAG API key (optional)",
    )
    # MCP transport
    parser.add_argument(
        "--mcp-transport",
        choices=["stdio", "sse", "streamable-http"],
        default="streamable-http",
        help=f"MCP transport (default: streamable-http)",
    )
    parser.add_argument(
        "--mcp-http-host",
        default=MCPSettings.host,
        help=f"MCP HTTP host (default: {MCPSettings.host})",
    )
    parser.add_argument(
        "--mcp-http-port",
        type=int,
        default=MCPSettings.port,
        help=f"MCP HTTP port (default: {MCPSettings.port})",
    )
    parser.add_argument(
        "--mcp-http-path",
        type=str,
        default="/",
        help=(
            "MCP HTTP base/mount path"
            f"(default: {MCPSettings.mount_path})"
        ),
    )
    parser.add_argument(
        "--mcp-http-stateless",
        action="store_true",
        help="Enable stateless HTTP mode (new session per request)",
    )
    parser.add_argument(
        "--mcp-http-json-response",
        action="store_true",
        help="Return JSON responses instead of SSE for HTTP",
    )
    return parser.parse_args()


args = parse_args()

LIGHTRAG = LightRAGSettings(
    host=args.host,
    port=args.port,
    api_key=args.api_key,
)

TRANSPORT = args.mcp_transport

MCP = MCPSettings(
    host=args.mcp_http_host,
    port=args.mcp_http_port,
    mount_path=_normalize_path(args.mcp_http_path),
    stateless_http=args.mcp_http_stateless,
    json_response=args.mcp_http_json_response,
)
