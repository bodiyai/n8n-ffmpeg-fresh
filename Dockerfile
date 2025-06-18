FROM node:22-bookworm-slim

# Обновляем пакеты и устанавливаем зависимости для Chrome
RUN apt-get update && apt-get install -y \
    libnss3 \
    libdbus-1-3 \
    libatk1.0-0 \
    libgbm-dev \
    libasound2 \
    libxrandr2 \
    libxkbcommon-dev \
    libxfixes3 \
    libxcomposite1 \
    libxdamage1 \
    libatk-bridge2.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    libcups2 \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем n8n глобально
RUN npm install -g n8n@latest && npm cache clean --force

# Создаем рабочую директорию
WORKDIR /app

# Создаем package.json для Remotion проекта
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "type": "module"}' > package.json

# Устанавливаем Remotion пакеты
RUN npm install \
    @remotion/cli@latest \
    @remotion/renderer@latest \
    @remotion/bundler@latest \
    @remotion/media-utils@latest \
    @remotion/shapes@latest \
    @remotion/transitions@latest \
    @remotion/fonts@latest \
    @remotion/noise@latest \
    && npm cache clean --force

# Устанавливаем Chrome Headless Shell
RUN npx remotion browser ensure

# Настройки окружения
ENV N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/ \
    PATH="/app/node_modules/.bin:${PATH}" \
    NODE_OPTIONS="--max-old-space-size=4096"

# Открываем порт для n8n
EXPOSE 5678

# Возвращаемся в корневую директорию для n8n
WORKDIR /

# Запускаем n8n
CMD ["n8n", "start"]
