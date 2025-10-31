# Stage 1 - Build the app
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libzip-dev libpng-dev libxml2-dev curl \
    && docker-php-ext-install pdo pdo_pgsql gd zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy everything (so artisan, routes, etc. exist before composer runs)
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP dependencies (ignore dev + platform reqs)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Fix permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 for Render
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
