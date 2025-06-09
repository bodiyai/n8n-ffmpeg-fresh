FROM node:18-alpine

# Ставим самый свежий FFmpeg
RUN apk add --no-cache ffmpeg

# Ставим самый свежий n8n
RUN npm install -g n8n@latest

EXPOSE 5678
CMD ["n8n", "start"]
