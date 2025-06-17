FROM node:20-bullseye

# Устанавливаем системные зависимости (БЕЗ ffmpeg из репозитория)
RUN apt update && apt install -y \
    wget \
    xz-utils \
    python3 \
    python3-pip \
    build-essential \
    make \
    g++ \
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
    libgtk-3-0 \
    libxcb-dri3-0

# Скачиваем СТАТИЧЕСКУЮ сборку FFmpeg 7.1
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
RUN tar -xf ffmpeg-release-amd64-static.tar.xz
RUN mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/
RUN mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/
RUN chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Очищаем временные файлы FFmpeg
RUN rm -rf ffmpeg-release-amd64-static.tar.xz ffmpeg-*-amd64-static/

# Обновляем npm
RUN npm install -g npm@latest

# Устанавливаем n8n
RUN npm install -g n8n@latest

# Создаем рабочую директорию для Remotion
WORKDIR /app

# Создаем package.json для локальной установки Remotion
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "dependencies": {}}' > package.json

# Устанавливаем Remotion локально
RUN npm install \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest

# Создаем симлинк для remotion CLI
RUN ln -s /app/node_modules/.bin/remotion /usr/local/bin/remotion

# Проверяем установку
RUN echo "=== NODE VERSION ===" && node --version && \
    echo "=== NPM VERSION ===" && npm --version && \
    echo "=== N8N VERSION ===" && n8n --version && \
    echo "=== REMOTION VERSION ===" && remotion --version && \
    echo "=== FFMPEG VERSION CHECK ===" && \
    /usr/local/bin/ffmpeg -version && \
    echo "=== LOCAL REMOTION PACKAGES ===" && \
    ls -la /app/node_modules/.bin/ | grep remotion && \
    echo "=== END VERSION CHECK ==="

# Настройки окружения
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/

# Добавляем локальные модули в PATH
ENV PATH="/app/node_modules/.bin:${PATH}"

# Настройки для Remotion в headless режиме
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV NODE_OPTIONS="--max-old-space-size=4096"

EXPOSE 5678

# Возвращаемся в root для запуска n8n
WORKDIR /

CMD ["n8n", "start"]
