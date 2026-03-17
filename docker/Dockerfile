# ==========================================
# 阶段 1: 编译前端页面
# ==========================================
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/ ./
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/
RUN bun install && bun run build

# ==========================================
# 阶段 2: 构建最终运行环境
# ==========================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# 安装 nginx 和 procps (用于 service 命令)
RUN apt-get update && apt-get install -y nginx procps && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. 安装 Python 后端
WORKDIR /app/python
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
COPY python/ ./
RUN uv sync --locked

# 2. 注入前端产物
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

# 3. 配置 Nginx
RUN echo 'server { \
    listen 80; \
    location / { \
        root /app/frontend/dist; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/sites-available/default

# 4. 复制启动脚本
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 80

# 启动容器入口
CMD ["/bin/bash", "/app/start.sh"]
