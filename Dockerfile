# === Tahap 1: Kompilasi Frontend Assets ===
FROM node:20-alpine AS assets-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# === Tahap 2: Image Production Utama ===
FROM webdevops/php-nginx:8.4

ENV WEB_DOCUMENT_ROOT=/app/public
WORKDIR /app

COPY . .

COPY --from=assets-builder /app/public/build ./public/build

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R application:application /app/storage /app/bootstrap/cache

EXPOSE 80