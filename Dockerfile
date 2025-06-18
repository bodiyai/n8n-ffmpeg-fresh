FROM node:20-bullseye-slim

# Устанавливаем системные зависимости (БЕЗ ffmpeg - он встроен в Remotion v4+)
RUN apt update && apt install -y --no-install-recommends \
    wget \
    curl \
    chromium \
    fonts-liberation \
    ca-certificates \
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем n8n глобально
RUN npm install -g n8n@latest && npm cache clean --force

# Создаем рабочую директорию для Remotion
WORKDIR /app

# Создаем package.json для Remotion
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "type": "module"}' > package.json

# Устанавливаем Remotion пакеты (v4+ включает встроенный FFmpeg)
RUN npm install --save \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force

# Создаем симлинки для удобства
RUN ln -sf /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Проверяем что все установилось
RUN ls -la /app/node_modules/.bin/ && \
    ls -la /app/node_modules/@remotion/ && \
    remotion --version && \
    echo "Remotion installed successfully"

# Настройки окружения
ENV N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/ \
    PATH="/app/node_modules/.bin:${PATH}" \
    NODE_OPTIONS="--max-old-space-size=2048" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    REMOTION_ENABLE_MULTIPROCESS_ON_LINUX=true

# Открываем порт для n8n
EXPOSE 5678

# Возвращаемся в корневую директорию для n8n
WORKDIR /

# Запускаем n8n
CMD ["n8n", "start"]
