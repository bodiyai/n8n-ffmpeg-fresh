FROM node:20-slim

# Сброс кэша с уникальным значением
ARG CACHEBUST=1
RUN echo "Cache bust: $(date) - $CACHEBUST" > /tmp/cache_bust.txt

# Установка Chrome и зависимостей
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

# Установка n8n глобально
RUN npm install -g n8n@latest

# Создание минимального проекта Remotion
RUN mkdir -p src && echo "import { defineComposition } from 'remotion'; defineComposition({ id: 'HelloWorld', component: () => <h1>Hello</h1> });" > src/index.ts

# Установка зависимостей Remotion
RUN echo '{"name":"app","version":"1.0.0","dependencies":{"@remotion/cli":"4.0.315","@remotion/renderer":"4.0.315","react":"18.2.0","react-dom":"18.2.0","typescript":"^5.0.0"}}' > package.json
RUN npm install

# Установка Remotion глобально
RUN npm install -g @remotion/cli@4.0.315

# Создание директории для n8n
RUN mkdir -p /root/.n8n

# Переменные окружения
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV NODE_OPTIONS=--max-old-space-size=2048
ENV NODE_ENV=production
ENV N8N_ENCRYPTION_KEY=n8n-railway-secret-key-12345678901234567890
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_EDITOR_BASE_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_RUNNERS_ENABLED=true
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=$PORT
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Экспорт портов
EXPOSE $PORT 3000

# Запуск n8n с явным указанием порта через переменную
CMD sh -c "n8n start"
