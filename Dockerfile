FROM node:22-bookworm-slim

# Cache buster для принудительной пересборки
RUN echo "build-$(date +%s)" > /tmp/build_id

# Системные зависимости для Chrome
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

# Создаем package.json
RUN echo '{"name": "n8n-remotion", "version": "1.0.0", "type": "module"}' > package.json

# Устанавливаем Remotion пакеты локально
RUN npm install \
    @remotion/cli@4.0.315 \
    @remotion/renderer@4.0.315 \
    @remotion/bundler@4.0.315 \
    @remotion/media-utils@4.0.315 \
    @remotion/shapes@4.0.315 \
    @remotion/transitions@4.0.315 \
    @remotion/fonts@4.0.315 \
    @remotion/noise@4.0.315 \
    && npm cache clean --force

# Проверяем что Remotion установился
RUN npx remotion --version

# Устанавливаем Chrome Headless Shell
RUN npx remotion browser ensure

# Переменные окружения
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV PATH="/app/node_modules/.bin:$PATH"

EXPOSE 5678

CMD ["n8n", "start"]
