# # --- Base image ---
# FROM node:20-alpine

# # --- System packages for Flowise dependencies ---
# RUN apk add --no-cache \
#     libc6-compat \
#     python3 \
#     make \
#     g++ \
#     build-base \
#     cairo-dev \
#     pango-dev \
#     chromium \
#     curl

# # --- Global PNPM installation ---
# RUN npm install -g pnpm
# RUN pnpm config set ignore-scripts false
# RUN pnpm set enable-pre-post-scripts true

# # --- Environment variables for Puppeteer & Node ---
# ENV PUPPETEER_SKIP_DOWNLOAD=true
# ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
# ENV NODE_OPTIONS=--max-old-space-size=8192
# ENV HOST=0.0.0.0
# ENV PORT=3000

# # --- Working directory ---
# WORKDIR /usr/src

# # --- Copy all project files ---
# COPY . .

# # --- Install dependencies ---
# RUN pnpm config set ignore-scripts false
# RUN pnpm install --frozen-lockfile

# RUN pnpm approve-builds

# # --- Build Flowise (creates dist/index.js) ---
# RUN pnpm build

# # --- Create persistent data & log directories ---
# RUN mkdir -p /usr/src/data/logs
# RUN chmod -R 777 /usr/src/data

# # --- Define Flowise data/log envs ---
# ENV FLOWISE_DATA_DIR=/usr/src/data
# ENV FLOWISE_LOG_DIR=/usr/src/data/logs
# ENV FLOWISE_LOG_PATH=/usr/src/data/logs

# # --- Expose the web port ---
# EXPOSE 3000

# # --- Start Flowise directly (no oclif CLI) ---
# CMD ["pnpm", "exec", "node", "packages/server/dist/index.js"]

# --------------------------------------------------
# Flowise 3.0.8 - Render Starter+ Dockerfile
# Persistent data + all Flowise features enabled
# --------------------------------------------------

# --------------------------------------------------
# Flowise 3.0.8 - Render Full Feature Dockerfile
# Node 20 compatible + Puppeteer/Sharp/Canvas support
# --------------------------------------------------

FROM node:20-alpine

# --- System dependencies for Puppeteer, Sharp, PDF, etc. ---
RUN apk add --update --no-cache \
  libc6-compat \
  python3 \
  make \
  g++ \
  build-base \
  cairo-dev \
  pango-dev \
  libjpeg-turbo-dev \
  giflib-dev \
  freetype-dev \
  nss \
  alsa-lib \
  chromium \
  curl \
  ttf-freefont

# --- Global PNPM installation ---
RUN npm install -g pnpm

# --- PNPM config: allow native builds & scripts ---
RUN pnpm config set ignore-scripts false
RUN pnpm config set allowed-builds "@swc/core canvas core-js core-js-pure esbuild protobufjs puppeteer sharp"

# --- Puppeteer / Node environment ---
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV HOST=0.0.0.0
ENV PORT=3000

WORKDIR /usr/src

# --- Copy project files ---
COPY . .

# --- Install dependencies & build Flowise ---
RUN pnpm install --no-frozen-lockfile
RUN pnpm build

# --- Persistent data/logs directory ---
RUN mkdir -p /usr/src/data/logs
RUN chmod -R 777 /usr/src/data

ENV FLOWISE_DATA_DIR=/usr/src/data
ENV FLOWISE_LOG_DIR=/usr/src/data/logs
ENV FLOWISE_LOG_PATH=/usr/src/data/logs

EXPOSE 3000

# --- Start Flowise ---
CMD ["pnpm", "start"]

