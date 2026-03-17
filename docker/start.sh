#!/bin/bash
# 1. 以后台方式启动 Nginx (防止它占用前台进程)
service nginx start

# 2. 以后台方式启动 Python 后端 (放在后台运行)
# 注意：你需要安装一个简单的进程守护，或者确保后端一直跑
# 这里我们直接启动它，并在最后用 tail 保持容器运行
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000 &

# 3. 保持容器主进程不退出 (K8s 容器必须有一个主进程在运行)
# 使用 tail 监听一个文件，或者简单的一条死循环
tail -f /dev/null
