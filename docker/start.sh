#!/bin/bash
# 给予权限
chmod -R 777 /data

# 启动 Nginx (使用 -g daemon off 让它在当前进程运行，防止被杀)
nginx -g "daemon on;"

# 启动 Python 后端 (这是容器的主进程)
# 只要这个进程活着，容器就不会被杀掉
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
