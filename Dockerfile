FROM node:20-bullseye-slim

# Устанавливаем системные зависимости включая FFmpeg из репозитория
RUN apt update && apt install -y --no-install-recommends \
    wget \
    curl \
    chromium \
    fonts-liberation \
    ca-certificates \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем n8n
RUN npm install -g n8n@latest && npm cache clean --force

# Создаем рабочую директорию
WORKDIR /app

# Создаем package.json и устанавливаем Remotion
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "type": "module"}' > package.json

# Устанавливаем Remotion пакеты
RUN npm install --save \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force

# Создаем симлинк
RUN ln -sf /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Проверяем установку
RUN which ffmpeg && ffmpeg -version && \
    which ffprobe && ffprobe -version && \
    ls -la /app/node_modules/.bin/ && \
    /app/node_modules/.bin/remotion --version

# Настройки окружения
ENV N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/ \
    PATH="/app/node_modules/.bin:${PATH}" \
    NODE_OPTIONS="--max-old-space-size=2048" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

EXPOSE 5678

# Возвращаемся в корневую директорию для n8n
WORKDIR /

CMD ["n8n", "start"]
