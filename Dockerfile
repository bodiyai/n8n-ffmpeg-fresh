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

EXPOSE 5678
CMD ["n8n", "start"]
