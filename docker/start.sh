#!/bin/bash
# 启动 Nginx
nginx -g "daemon off;" &
# 启动后端 (必须使用 exec 让 Python 成为容器内主进程，或者保持在后台)
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 127.0.0.1 --port 8000
