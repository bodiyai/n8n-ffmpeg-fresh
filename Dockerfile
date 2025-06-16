FROM ubuntu:22.04

# Устанавливаем зависимости и свежий Node.js
RUN apt update && apt install -y wget xz-utils curl

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs

# Скачиваем СТАТИЧЕСКУЮ сборку FFmpeg 7.1
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
RUN tar -xf ffmpeg-release-amd64-static.tar.xz
RUN mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/
RUN mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/
RUN chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Устанавливаем n8n
RUN npm install -g n8n@latest

# Устанавливаем Remotion и все зависимости
RUN npm install -g @remotion/cli@latest
RUN npm install -g @remotion/renderer@latest
RUN npm install -g @remotion/media-utils@latest
RUN npm install -g @remotion/shapes@latest
RUN npm install -g @remotion/transitions@latest
RUN npm install -g @remotion/fonts@latest
RUN npm install -g @remotion/noise@latest

# Устанавливаем дополнительные зависимости для работы Remotion в контейнере
RUN apt install -y libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2

# Проверяем версии (БЕЗ Remotion)
RUN echo "=== NODE VERSION ===" && node --version && \
    echo "=== NPM VERSION ===" && npm --version && \
    echo "=== FFMPEG VERSION CHECK ===" && \
    ffmpeg -version && \
    echo "=== END VERSION CHECK ==="

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/

EXPOSE 5678

CMD ["n8n", "start"]
