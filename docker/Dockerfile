# 阶段 1: 编译前端
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/ ./
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/
RUN bun install && bun run build

# 阶段 2: 构建最终环境
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
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

# 3. 配置 Nginx (万能转发)
# 不管前端发什么请求，找不到文件就往后端扔
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /app/frontend/dist; \
    index index.html; \
    \
    # 静态文件 \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # 转发 API \
    location /api/ { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_set_header Host $host; \
    } \
    \
    # 强制劫持 healthz 请求 \
    location /healthz { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/sites-available/default && ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# 4. 设置脚本
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 80
CMD ["/bin/bash", "/app/start.sh"]
