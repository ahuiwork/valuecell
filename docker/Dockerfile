# ==========================================
# 阶段 1: 编译前端页面 (使用 Bun 环境)
# ==========================================
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend

COPY frontend/ ./

# 注入环境变量
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/

# 使用 bun 打包
RUN bun install && bun run build

# ==========================================
# 阶段 2: 构建后端与最终运行环境
# ==========================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# 安装 Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- 1. 安装 Python 后端 ----
WORKDIR /app/python
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
COPY python/ ./
RUN uv sync --locked

# ---- 2. 注入前端产物 ----
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

# ---- 3. 配置 Nginx 路由规则 ----
RUN echo 'server { \
    listen 80; \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        root /app/frontend/dist; \
        expires 1y; \
        add_header Cache-Control "public"; \
    } \
    location / { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
        proxy_buffering off; \
        proxy_cache off; \
    } \
}' > /etc/nginx/sites-available/default

# ---- 4. 设置启动脚本 ----
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 80

# 直接运行启动脚本
CMD ["/bin/bash", "/app/start.sh"]
