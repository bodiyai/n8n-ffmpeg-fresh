FROM node:20-slim

# Устанавливаем Chrome и зависимости
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libgbm1 \
    xdg-utils \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Устанавливаем n8n
RUN npm install -g n8n@latest

# Создаем package.json для Remotion
RUN echo '{"name":"app","version":"1.0.0","dependencies":{"@remotion/cli":"4.0.315","@remotion/renderer":"4.0.315","@remotion/lambda":"4.0.315","react":"18.2.0","react-dom":"18.2.0","typescript":"^5.0.0"}}' > package.json

# Устанавливаем Remotion
RUN npm install

# Создаем директорию для n8n
RUN mkdir -p /root/.n8n

# Переменные окружения
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV NODE_OPTIONS=--max-old-space-size=2048
ENV NODE_ENV=production

# Переменные n8n - ТОЛЬКО САМЫЕ НЕОБХОДИМЫЕ
ENV N8N_ENCRYPTION_KEY=n8n-railway-secret-key-12345678901234567890
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_EDITOR_BASE_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_RUNNERS_ENABLED=true

# Railway требует биндинг на 0.0.0.0 и порт из $PORT
ENV N8N_HOST=0.0.0.0
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Экспортируем стандартный порт
EXPOSE 5678

# Простой запуск - Railway автоматически передает $PORT
CMD n8n start
