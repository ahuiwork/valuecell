#!/bin/bash
# 确保挂载的数据库目录有权限
if [ -d "/data" ]; then
    chmod -R 777 /data
fi

# 启动 Nginx (后台运行)
service nginx start

# 启动 Python 后端 (作为主进程前台运行)
# 这样容器的 PID 1 就是 Python，不会被系统杀掉
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
