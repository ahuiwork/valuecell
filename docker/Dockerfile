# 阶段 1: 编译前端
FROM oven/bun:1.3 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/ ./
ENV VITE_API_URL=/
ENV VITE_API_BASE_URL=/
ENV NEXT_PUBLIC_API_URL=/
RUN bun install && bun run build

# 阶段 2: 最终环境
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
RUN apt-get update && apt-get install -y nginx procps && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY python/ /app/python/
COPY --from=frontend-builder /app/frontend/build/client /app/frontend/dist

RUN echo 'server { \
    listen 80; \
    location / { root /app/frontend/dist; index index.html; try_files $uri $uri/ /index.html; } \
    location /api/ { proxy_pass http://127.0.0.1:8000; proxy_set_header Host $host; } \
}' > /etc/nginx/sites-available/default && ln -sf /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default

COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh
EXPOSE 80
CMD ["/bin/bash", "/app/start.sh"]
