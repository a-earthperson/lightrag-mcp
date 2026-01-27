#!/usr/bin/env sh
set -e

LIGHTRAG_HOST="${LIGHTRAG_HOST:-lightrag}"
LIGHTRAG_PORT="${LIGHTRAG_PORT:-9621}"
LIGHTRAG_API_KEY="${LIGHTRAG_API_KEY:-}"

MCP_TRANSPORT="${MCP_TRANSPORT:-streamable-http}"
MCP_HOST="${MCP_HOST:-0.0.0.0}"
MCP_PORT="${MCP_PORT:-8000}"
MCP_STREAMABLE_HTTP_PATH="${MCP_STREAMABLE_HTTP_PATH:-/mcp}"
MCP_STATELESS_HTTP="${MCP_STATELESS_HTTP:-false}"
MCP_JSON_RESPONSE="${MCP_JSON_RESPONSE:-false}"

ARGS="--host ${LIGHTRAG_HOST} --port ${LIGHTRAG_PORT} --mcp-transport ${MCP_TRANSPORT} --mcp-host ${MCP_HOST} --mcp-port ${MCP_PORT} --mcp-streamable-http-path ${MCP_STREAMABLE_HTTP_PATH}"

if [ -n "${LIGHTRAG_API_KEY}" ]; then
  ARGS="${ARGS} --api-key ${LIGHTRAG_API_KEY}"
fi

case "$(printf '%s' "${MCP_STATELESS_HTTP}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes|y) ARGS="${ARGS} --mcp-stateless-http" ;;
esac

case "$(printf '%s' "${MCP_JSON_RESPONSE}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes|y) ARGS="${ARGS} --mcp-json-response" ;;
esac

exec lightrag-mcp ${ARGS} "$@"
