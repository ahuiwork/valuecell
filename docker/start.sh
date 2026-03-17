#!/bin/bash
# 1. 后台启动 Nginx
nginx -g "daemon on;"

# 2. 前台启动 Python 后端，让它直接输出到 Docker Logs
# 这样就没有 Supervisor 来拦截日志并报错了
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
