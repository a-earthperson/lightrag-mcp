#!/usr/bin/env sh
set -e

LIGHTRAG_HOST="${LIGHTRAG_HOST:-lightrag}"
LIGHTRAG_PORT="${LIGHTRAG_PORT:-9621}"
LIGHTRAG_API_KEY="${LIGHTRAG_API_KEY:-}"

MCP_TRANSPORT="${MCP_TRANSPORT:-streamable-http}"
MCP_HTTP_HOST="${MCP_HTTP_HOST:-${MCP_HOST:-0.0.0.0}}"
MCP_HTTP_PORT="${MCP_HTTP_PORT:-${MCP_PORT:-8000}}"
MCP_HTTP_PATH="${MCP_HTTP_PATH:-${MCP_STREAMABLE_HTTP_PATH:-/}}"
MCP_HTTP_STATELESS="${MCP_HTTP_STATELESS:-${MCP_STATELESS_HTTP:-false}}"
MCP_HTTP_JSON_RESPONSE="${MCP_HTTP_JSON_RESPONSE:-${MCP_JSON_RESPONSE:-false}}"

ARGS="--host ${LIGHTRAG_HOST} --port ${LIGHTRAG_PORT} --mcp-transport ${MCP_TRANSPORT} --mcp-http-host ${MCP_HTTP_HOST} --mcp-http-port ${MCP_HTTP_PORT} --mcp-http-path ${MCP_HTTP_PATH}"

if [ -n "${LIGHTRAG_API_KEY}" ]; then
  ARGS="${ARGS} --api-key ${LIGHTRAG_API_KEY}"
fi

case "$(printf '%s' "${MCP_HTTP_STATELESS}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes|y) ARGS="${ARGS} --mcp-http-stateless" ;;
esac

case "$(printf '%s' "${MCP_HTTP_JSON_RESPONSE}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes|y) ARGS="${ARGS} --mcp-http-json-response" ;;
esac

exec lightrag-mcp ${ARGS} "$@"
