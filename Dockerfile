# Use official PHP image with Composer and Node preinstalled
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl nodejs npm \
    && docker-php-ext-install pdo pdo_mysql

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Build frontend
RUN npm install && npm run build

# Laravel setup
RUN php artisan key:generate --force

# Expose port
EXPOSE 80

# Start Laravel server
CMD php artisan serve --host=0.0.0.0 --port=80
