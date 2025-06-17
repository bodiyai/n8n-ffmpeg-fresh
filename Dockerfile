FROM node:20-bullseye-slim

# Устанавливаем все зависимости одной командой и очищаем кеш
RUN apt update && apt install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    xz-utils \
    chromium \
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
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Скачиваем FFmpeg и сразу очищаем временные файлы
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && tar -xf ffmpeg-release-amd64-static.tar.xz \
    && mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ \
    && mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ \
    && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
    && rm -rf ffmpeg-release-amd64-static.tar.xz ffmpeg-*-amd64-static/

# Устанавливаем n8n
RUN npm install -g npm@latest n8n@latest && npm cache clean --force

# Создаем рабочую директорию и устанавливаем ВСЕ необходимые Remotion пакеты
WORKDIR /app
RUN echo '{"name": "n8n-remotion", "version": "1.0.0"}' > package.json \
    && npm install --no-save \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force \
    && ln -s /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Проверяем установку браузера для Remotion
RUN npx remotion browser ensure

# Проверяем установку (краткая версия)
RUN echo "=== VERSIONS ===" && \
    node --version && \
    n8n --version && \
    remotion --version && \
    /usr/local/bin/ffmpeg -version | head -1 && \
    chromium --version && \
    echo "=== ALL READY ==="

# Настройки окружения
ENV N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/ \
    PATH="/app/node_modules/.bin:${PATH}" \
    NODE_OPTIONS="--max-old-space-size=4096" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium" \
    CHROME_BIN="/usr/bin/chromium" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

EXPOSE 5678

# Возвращаемся в root для запуска n8n
WORKDIR /

CMD ["n8n", "start"]
