#!/bin/bash
chmod -R 777 /data
nginx -g "daemon on;"
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
