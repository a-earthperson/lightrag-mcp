############################
# Builder: resolve/install deps into a venv
############################
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    UV_PROJECT_ENVIRONMENT=/opt/venv

# uv is used by the repo; installing it once in the builder keeps the runtime image small.
RUN python -m venv "${VIRTUAL_ENV}" \
 && pip install --no-cache-dir -U pip \
 && pip install --no-cache-dir uv

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project

COPY src ./src
COPY README.md LICENSE ./
RUN uv sync --frozen

############################
# Runtime: copy venv only
############################
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

RUN addgroup --system app && adduser --system --ingroup app app

COPY --from=builder /opt/venv /opt/venv
COPY docker/entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

USER app
WORKDIR /app

# Runtime-configurable LightRAG + MCP parameters (override via env or docker run -e)
ENV LIGHTRAG_HOST=lightrag \
    LIGHTRAG_PORT=9621 \
    LIGHTRAG_API_KEY= \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000 \
    MCP_STREAMABLE_HTTP_PATH=/mcp \
    MCP_STATELESS_HTTP=false \
    MCP_JSON_RESPONSE=false

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import os, socket, sys; transport=os.getenv('MCP_TRANSPORT','streamable-http'); if transport == 'stdio': sys.exit(0); port=int(os.getenv('MCP_PORT','8000')); s=socket.socket(); s.settimeout(2); s.connect(('127.0.0.1', port)); s.close()"

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD []