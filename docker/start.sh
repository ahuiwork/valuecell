#!/bin/bash
# 给予权限
chmod -R 777 /data

# ★★★ 手术刀操作：把前端 dist 里所有文件里的 healthz 替换成 / ★★★
# 使用 sed 命令批量替换所有 js 文件中的硬编码域名
find /app/frontend/dist -name "*.js" -exec sed -i 's|https://healthz|/|g' {} +
find /app/frontend/dist -name "*.js" -exec sed -i 's|http://healthz|/|g' {} +

# 启动 Nginx
nginx

# 启动 Python 后端
cd /app/python && uv run uvicorn valuecell.server.api.app:app --host 0.0.0.0 --port 8000
