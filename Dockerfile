FROM ubuntu:22.04

# Устанавливаем зависимости
RUN apt update && apt install -y wget xz-utils curl

# Устанавливаем Node.js 20 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt install -y nodejs

# Скачиваем СТАТИЧЕСКУЮ сборку FFmpeg 7.1
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
RUN tar -xf ffmpeg-release-amd64-static.tar.xz
RUN mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/
RUN mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/
RUN chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Очищаем временные файлы FFmpeg
RUN rm -rf ffmpeg-release-amd64-static.tar.xz ffmpeg-*-amd64-static/

# Устанавливаем дополнительные зависимости для работы Remotion в контейнере
RUN apt install -y \
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

# Устанавливаем n8n
RUN npm install -g n8n@latest

# Устанавливаем Remotion и все зависимости
RUN npm install -g \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest

# Проверяем версии
RUN echo "=== NODE VERSION ===" && node --version && \
    echo "=== NPM VERSION ===" && npm --version && \
    echo "=== N8N VERSION ===" && n8n --version && \
    echo "=== REMOTION VERSION ===" && remotion --version && \
    echo "=== FFMPEG VERSION CHECK ===" && \
    ffmpeg -version && \
    echo "=== END VERSION CHECK ==="

# Настройки окружения
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/

# Настройки для Remotion в headless режиме
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

EXPOSE 5678

CMD ["n8n", "start"]
