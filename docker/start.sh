#!/bin/bash
# 给予数据目录权限
chmod -R 777 /data

# 1. 强制将前端产物里所有硬编码的 'https://healthz' 替换为 '/'
# 这样前端代码在加载时，就会请求当前域名而非非法域名
find /app/frontend/dist -type f \( -name "*.js" -o -name "*.html" \) -exec sed -i 's|https://healthz|/|g' {} +
find /app/frontend/dist -type f \( -name "*.js" -o -name "*.html" \) -exec sed -i 's|http://healthz|/|g' {} +

# 2. 启动 Nginx
nginx

# 3. 以后台方式启动 Python 后端，并把日志存到 /app/backend.log 以便排查
# 注意：使用 exec 可以让 python 进程成为容器主进程，这样容器更稳
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000 > /app/backend.log 2>&1
