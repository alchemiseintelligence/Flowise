# Build local monorepo image
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 flowise

FROM node:20-alpine
RUN apk add --update libc6-compat python3 make g++
# needed for pdfjs-dist
RUN apk add --no-cache build-base cairo-dev pango-dev

# Install Chromium
RUN apk add --no-cache chromium

# Install curl for container-level health checks
# Fixes: https://github.com/FlowiseAI/Flowise/issues/4126
RUN apk add --no-cache curl

#install PNPM globaly
RUN npm install -g pnpm

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

ENV NODE_OPTIONS=--max-old-space-size=8192

WORKDIR /usr/src

# Copy app source
COPY . .

RUN pnpm install

RUN pnpm build

# ✅ Fix missing log directory & host binding
RUN mkdir -p /opt/render/.flowise/log
RUN chmod -R 777 /opt/render/.flowise
ENV FLOWISE_DATA_DIR=/opt/render/.flowise
ENV FLOWISE_LOG_DIR=/opt/render/.flowise/log
ENV HOST=0.0.0.0

EXPOSE 3000

# CMD [ "pnpm", "start" ]
# CMD ["pnpm", "exec", "node", "packages/server/bin/run", "server"]
CMD ["pnpm", "exec", "node", "packages/server/dist/index.js"]
