#!/bin/bash
# 给予数据权限
chmod -R 777 /data

# 启动 Nginx (放在后台运行)
nginx

# 启动 Python 后端 (放在后台运行，并将所有输出写入日志文件)
# nohup 可以防止终端关闭导致后端进程退出
cd /app/python && nohup uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000 > /app/backend.log 2>&1 &

# 保持容器主进程不退出 (这是关键！)
tail -f /dev/null
