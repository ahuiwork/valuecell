# 阶段 1: 编译前端
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/ ./
# 这里注入一个最通用的 API 地址，强制前端不要去请求 healthz 而是请求当前域名的 /api
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/
# 如果项目强制依赖 healthz 检查，我们在打包时直接通过环境变量把它“虚构”掉
ENV VITE_HEALTH_CHECK_URL=/api/health
RUN bun install && bun run build

# 阶段 2: 最终运行环境
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
RUN apt-get update && apt-get install -y nginx procps && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# 1. 安装后端
WORKDIR /app/python
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
COPY python/ ./
RUN uv sync --locked

# 2. 注入前端产物
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

# 3. 配置 Nginx：劫持 healthz 请求指向后端
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /app/frontend/dist; \
    index index.html; \
    location / { try_files $uri $uri/ /index.html; } \
    location /api/ { proxy_pass http://127.0.0.1:8000; proxy_set_header Host $host; } \
    location /healthz { proxy_pass http://127.0.0.1:8000; } \
}' > /etc/nginx/sites-available/default && ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# 4. 启动脚本
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh
EXPOSE 80
CMD ["/bin/bash", "/app/start.sh"]
