# -----------------------------
# Stage 1 — Build dependencies
# -----------------------------
FROM composer:2.7 AS vendor

WORKDIR /app

# Copy only composer files first for caching
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --optimize-autoloader --ignore-platform-reqs

# -----------------------------
# Stage 2 — Build frontend
# -----------------------------
FROM node:22 AS assets

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# -----------------------------
# Stage 3 — Final runtime image
# -----------------------------
FROM php:8.2-apache

# Enable PHP extensions & Apache modules
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip \
    && a2enmod rewrite

# Set the correct document root for Laravel
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/000-default.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

# Copy the application source (but NOT your local .env)
COPY . .
# bring in vendor deps and built assets from previous stages
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build

# Make sure storage is writable
RUN chown -R www-data:www-data storage bootstrap/cache && chmod -R 755 storage bootstrap/cache

# Clear Laravel caches (safe even if .env missing at build time)
RUN php artisan config:clear || true && php artisan route:clear || true && php artisan view:clear || true

EXPOSE 80
# When the container starts on Render, run migrations and start Apache
CMD php artisan migrate --force && apache2-foreground
