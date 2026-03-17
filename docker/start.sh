#!/bin/bash
# 启动 Nginx，并确保它在后台运行
nginx -g "daemon on;"

# 启动后端，直接输出到前台
# 这样所有 Python 日志直接作为容器的主日志，不会报错
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
