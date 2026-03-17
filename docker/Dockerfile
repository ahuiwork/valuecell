# ==========================================
# 阶段 1: 编译前端页面 (使用 Bun 环境)
# ==========================================
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend

# 复制前端代码
COPY frontend/ ./

# 注入环境变量
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/

# 使用 bun 安装并打包
RUN bun install && bun run build

# ==========================================
# 阶段 2: 构建后端与最终运行环境 (Python 环境)
# ==========================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# 安装 Nginx 和 Supervisor
RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- 1. 安装 Python 后端 ----
WORKDIR /app/python
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
COPY python/ ./
RUN uv sync --locked

# ---- 2. 注入前端产物 ----
# 根据你的 package.json，产物在 build/client
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

# ---- 3. 配置 Nginx ----
RUN echo 'server { \
    listen 80; \
    \
    location / { \
        root /app/frontend/dist; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location /api/ { \
        proxy_pass http://127.0.0.1:8000/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_buffering off; \
        proxy_cache off; \
        proxy_set_header Connection ""; \
        proxy_http_version 1.1; \
        chunked_transfer_encoding on; \
    } \
}' > /etc/nginx/sites-available/default

# ---- 4. 配置 Supervisor 大管家 ----
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:backend]\n\
command=uv run uvicorn valuecell.server.api.app:app --host 127.0.0.1 --port 8000\n\
directory=/app/python\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
' > /etc/supervisor/conf.d/supervisord.conf

# 最终对外开放 80 端口
EXPOSE 80

# ★★★ 必须有空格 ★★★
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
