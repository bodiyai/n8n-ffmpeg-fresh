# Используем официальный образ FFmpeg (самый свежий)
FROM jrottenberg/ffmpeg:latest-alpine AS ffmpeg

# Основной образ с Node.js
FROM node:18-alpine

# Копируем FFmpeg из официального образа
COPY --from=ffmpeg /usr/local /usr/local

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
