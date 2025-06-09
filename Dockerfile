FROM ubuntu:22.04

# Устанавливаем зависимости
RUN apt update && apt install -y wget xz-utils nodejs npm

# Скачиваем СТАТИЧЕСКУЮ сборку FFmpeg 7.1 напрямую с официального сайта
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
RUN tar -xf ffmpeg-release-amd64-static.tar.xz
RUN mv ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/
RUN mv ffmpeg-*-amd64-static/ffprobe /usr/local/bin/
RUN chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Устанавливаем n8n
RUN npm install -g n8n@latest

# Проверяем версию FFmpeg
RUN echo "=== FFMPEG VERSION CHECK ===" && \
    ffmpeg -version && \
    echo "=== END VERSION CHECK ==="

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/

EXPOSE 5678
CMD ["n8n", "start"]
