# Production image for the admin panel: a static Vite build served by nginx.
FROM node:22-alpine AS build
RUN corepack enable && corepack prepare pnpm@10.28.0 --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# Vite bakes these into the build, so they are build arguments, not runtime settings.
ARG VITE_API_URL
ARG VITE_API_BASE_URL
ENV VITE_API_URL=$VITE_API_URL \
    VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN test -n "$VITE_API_URL" && test -n "$VITE_API_BASE_URL" && pnpm run build

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
