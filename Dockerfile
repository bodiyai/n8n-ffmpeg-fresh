FROM node:20-bullseye-slim

# Устанавливаем системные зависимости
RUN apt update && apt install -y --no-install-recommends \
    wget \
    chromium \
    fonts-liberation \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем FFmpeg
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && tar -xf ffmpeg-release-amd64-static.tar.xz \
    && mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ \
    && mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ \
    && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
    && rm -rf ffmpeg-*

# Устанавливаем n8n
RUN npm install -g n8n@latest && npm cache clean --force

# Создаем рабочую директорию ОБЯЗАТЕЛЬНО
WORKDIR /app

# Создаем package.json и устанавливаем Remotion
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "type": "module"}' > package.json

# Устанавливаем Remotion пакеты с правильными флагами
RUN npm install --save \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force

# Создаем симлинк ПОСЛЕ установки
RUN ln -sf /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Проверяем что все на месте
RUN ls -la /app/node_modules/.bin/ && \
    ls -la /app/node_modules/@remotion/ && \
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
WORKDIR /

CMD ["n8n", "start"]
