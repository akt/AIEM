FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ ./src/
COPY migrations/ ./migrations/
COPY knexfile.ts ./

RUN npm run build

FROM node:20-alpine

RUN apk add --no-cache wget

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./migrations
COPY knexfile.ts ./

EXPOSE 3000

CMD ["sh", "-c", "npx knex migrate:latest --knexfile knexfile.ts && node dist/index.js"]
