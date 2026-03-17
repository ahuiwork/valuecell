#!/bin/bash
# 给予数据权限
chmod -R 777 /data

# 启动 Nginx
nginx

# 使用 nohup 启动，并将输出重定向到文件，彻底摆脱系统信号干扰
# 这样 uvicorn 就不会收到 CancelledError 信号了
cd /app/python && nohup uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000 > /app/backend.log 2>&1 &

# 保持容器主进程不退出 (这是关键！)
# 我们让这个脚本一直卡在这里，就不会因为脚本执行完而退出
tail -f /dev/null
