# ==========================================
# 阶段 1: 编译前端页面 (使用 Bun 环境)
# ==========================================
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend

COPY frontend/ ./

# 强制将 API 路径指向根路径的转发
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/

RUN bun install && bun run build

# ==========================================
# 阶段 2: 构建后端与最终运行环境
# ==========================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- 1. 安装 Python 后端 ----
WORKDIR /app/python
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
COPY python/ ./
RUN uv sync --locked

# ---- 2. 注入前端产物 ----
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

# ---- 3. 配置 Nginx (修正版：全路由转发) ----
RUN echo 'server { \
    listen 80; \
    \
    # 优先匹配静态资源 \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        root /app/frontend/dist; \
        expires 1y; \
        add_header Cache-Control "public"; \
    } \
    \
    # 核心修正：所有非静态请求(包括路由和API)全部转发给 FastAPI \
    location / { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
        proxy_buffering off; \
        proxy_cache off; \
        proxy_http_version 1.1; \
    } \
}' > /etc/nginx/sites-available/default

# ---- 4. 配置 Supervisor 大管家 ----
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
stdout_logfile=/dev/stdout\n\
stderr_logfile=/dev/stderr\n\
\n\
[program:backend]\n\
command=uv run uvicorn valuecell.server.api.app:app --host 127.0.0.1 --port 8000\n\
directory=/app/python\n\
stdout_logfile=/dev/stdout\n\
stderr_logfile=/dev/stderr\n\
' > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
