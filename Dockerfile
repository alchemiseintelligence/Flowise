# Build local monorepo image
# docker build --no-cache -t flowise .
# docker run -d -p 3000:3000 flowise

FROM node:20-alpine

# System libs
RUN apk add --update libc6-compat python3 make g++ build-base cairo-dev pango-dev chromium curl

# Install PNPM
RUN npm install -g pnpm

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV HOST=0.0.0.0
ENV PORT=3000

WORKDIR /usr/src

# Copy app source
COPY . .

# Install dependencies
RUN pnpm config set ignore-scripts false
RUN pnpm install --frozen-lockfile

# Build Flowise
RUN pnpm build

# ✅ Create writable data + log directories
RUN mkdir -p /usr/src/data/log
RUN chmod -R 777 /usr/src/data

# ✅ Set environment paths
ENV FLOWISE_DATA_DIR=/usr/src/data
ENV FLOWISE_LOG_DIR=/usr/src/data/log
ENV FLOWISE_LOG_PATH=/usr/src/data/log

# Expose web port
EXPOSE 3000

# ✅ Start Flowise server
CMD ["pnpm", "exec", "node", "packages/server/dist/index.js"]
