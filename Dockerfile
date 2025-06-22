FROM node:20-slim

# Принудительный сброс кэша с уникальным timestamp
ARG CACHEBUST=$(date +%s)
RUN echo "Cache bust: $CACHEBUST" > /tmp/cache_bust.txt

WORKDIR /app

# Установка зависимостей для обработки изображений и n8n
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Установка n8n глобально
RUN npm install -g n8n@latest

# Установка зависимостей для генерации картинок
RUN npm install -g sharp canvas

# Создание директории для n8n и монтирование Shared Disk
RUN mkdir -p /root/.n8n /data/n8n-output

# Переменные окружения
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_ENCRYPTION_KEY=n8n-railway-secret-key-12345678901234567890
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_EDITOR_BASE_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_RUNNERS_ENABLED=true
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV REMOTION_URL=https://remotion.n8nintegrationevgen.ru:4000/ # URL Remotion
ENV OUTPUT_DIR=/data/n8n-output # Папка для сохранения файлов

# Экспорт порта
EXPOSE 5678

# Запуск n8n
CMD ["n8n", "start"]
