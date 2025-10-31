# =============================
# ✅ Basewave - Laravel + Vite + PostgreSQL on Render
# =============================

FROM php:8.2-apache

WORKDIR /var/www/html

# Install system dependencies + PHP extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libpq-dev nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd \
    && a2enmod rewrite


# Copy the full project
COPY . .


# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Copy package files and build frontend
COPY package.json package-lock.json* ./
RUN npm ci && npm run build

# Laravel storage + cache permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Apache serve public folder
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Health check endpoint for Render
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/healthz || exit 1

# Expose HTTP port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
