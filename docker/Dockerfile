# ==========================================
# 阶段 1: 编译前端页面 (Node.js 环境)
# ==========================================
FROM node:20-slim AS frontend-builder
WORKDIR /app/frontend

# 开启 pnpm 支持
RUN corepack enable

# 复制前端代码
COPY frontend/ ./

# 注入环境变量，告诉前端把请求发给根目录的交通警察 (Nginx)
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/

# 自动判断并安装依赖进行打包 (产物将生成在 dist 目录)
RUN if[ -f "pnpm-lock.yaml" ]; then pnpm install && pnpm run build; else npm install && npm run build; fi

# ==========================================
# 阶段 2: 构建后端与最终运行环境 (Python 环境)
# ==========================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# 安装 Nginx (交通警察) 和 Supervisor (进程大管家)
RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- 1. 安装 Python 后端 ----
WORKDIR /app/python
# 利用缓存复制依赖文件
COPY python/pyproject.toml python/uv.lock ./
RUN uv sync --locked --no-install-project
# 复制剩余所有后端代码
COPY python/ ./
RUN uv sync --locked

# ---- 2. 注入前端产物 ----
# 从阶段 1 把打包好的漂亮网页复制过来
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# ---- 3. 配置 Nginx 路由规则 ----
RUN echo 'server { \
    listen 80; \
    \
    # 规则1：直接访问域名时，返回前端网页 \
    location / { \
        root /app/frontend/dist; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # 规则2：前端访问 /api/ 时，悄悄转发给内网的 Python 后端 \
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
# 让容器启动时同时拉起前端网关和后端服务
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

# 最终整个容器只对外开放 80 端口
EXPOSE 80

# 启动大管家（注意：CMD 和 [ 之间有空格，不会再错了！）
CMD["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
