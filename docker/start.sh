#!/bin/bash
chmod -R 777 /data
# 以后台启动 nginx
nginx
# 前台启动 python
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
