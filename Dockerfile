# --- Base image ---
FROM node:20-alpine

# --- System packages for Flowise dependencies ---
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++ \
    build-base \
    cairo-dev \
    pango-dev \
    chromium \
    curl

# --- Global PNPM installation ---
RUN pnpm config set ignore-scripts false
RUN npm install -g pnpm

# --- Environment variables for Puppeteer & Node ---
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV HOST=0.0.0.0
ENV PORT=3000

# --- Working directory ---
WORKDIR /usr/src

# --- Copy all project files ---
COPY . .

# --- Install dependencies ---
RUN pnpm config set ignore-scripts false
RUN pnpm install --frozen-lockfile

# --- Build Flowise (creates dist/index.js) ---
RUN pnpm build

# --- Create persistent data & log directories ---
RUN mkdir -p /usr/src/data/logs
RUN chmod -R 777 /usr/src/data

# --- Define Flowise data/log envs ---
ENV FLOWISE_DATA_DIR=/usr/src/data
ENV FLOWISE_LOG_DIR=/usr/src/data/logs
ENV FLOWISE_LOG_PATH=/usr/src/data/logs

# --- Expose the web port ---
EXPOSE 3000

# --- Start Flowise directly (no oclif CLI) ---
CMD ["pnpm", "exec", "node", "packages/server/dist/index.js"]
