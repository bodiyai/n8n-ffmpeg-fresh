# Используем официальный образ FFmpeg
FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg

# Основной образ с Node.js
FROM node:18-alpine

# Устанавливаем FFmpeg через пакетный менеджер Alpine (самый надежный способ)
RUN apk add --no-cache ffmpeg

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
