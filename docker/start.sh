#!/bin/bash
# 给予数据权限
if [ -d "/data" ]; then chmod -R 777 /data; fi
# 启动 nginx
nginx
# 直接运行后端（这是主进程，PID 1）
cd /app/python && uv run python -m valuecell.server.main --host 0.0.0.0 --port 8000
