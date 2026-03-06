# Simple Dockerfile for Vite + React + TypeScript
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm i -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/dist .
COPY public/vite.svg .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
