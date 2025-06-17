FROM node:20-alpine

# Устанавливаем системные зависимости одной командой
RUN apk add --no-cache \
    wget \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    && rm -rf /var/cache/apk/*

# Устанавливаем FFmpeg (статическая сборка)
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && tar -xf ffmpeg-release-amd64-static.tar.xz \
    && mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ \
    && mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ \
    && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
    && rm -rf ffmpeg-*

# Устанавливаем n8n глобально
RUN npm install -g n8n@latest && npm cache clean --force

# Создаем папку для Remotion и устанавливаем ВСЕ пакеты
WORKDIR /app
RUN echo '{"name": "n8n-remotion", "version": "1.0.0"}' > package.json \
    && npm install \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force \
    && ln -s /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Настройки окружения для всех компонентов
ENV N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/ \
    PATH="/app/node_modules/.bin:${PATH}" \
    NODE_OPTIONS="--max-old-space-size=2048" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

EXPOSE 5678

# Возвращаемся в root для запуска n8n
WORKDIR /

CMD ["n8n", "start"]
