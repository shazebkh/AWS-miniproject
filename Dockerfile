# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json ./
COPY bun.lock* ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source
COPY . .

# Build frontend
RUN npx vite build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy package files and install production deps
COPY package.json ./
RUN npm install --legacy-peer-deps --omit=dev

# Copy built frontend and source
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/apps ./apps
COPY --from=builder /app/packages ./packages
COPY server.ts ./
COPY tsconfig.json ./

# Install tsx for running TypeScript in production
RUN npm install tsx --save

EXPOSE 3000

CMD ["node", "--import", "tsx/esm", "server.ts"]
