FROM node:20-slim

# Устанавливаем Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Устанавливаем n8n
RUN npm install -g n8n

# Создаем файл для зависимостей Remotion
RUN echo '{"name":"app","version":"1.0.0","dependencies":{"@remotion/cli":"4.0.315","@remotion/renderer":"4.0.315","react":"18.2.0","react-dom":"18.2.0"}}' > package.json

# Устанавливаем Remotion
RUN npm install

# Переменные окружения
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV N8N_HOST=0.0.0.0
ENV WEBHOOK_URL=https://bodiyt.n8nintegrationevgen.ru/
ENV NODE_OPTIONS=--max-old-space-size=2048

# Запускаем n8n с портом от Railway
CMD ["sh", "-c", "n8n start --host=0.0.0.0 --port=$PORT"]
