# Use the official PHP image with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set Apache DocumentRoot to /public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy composer and lock files first
COPY composer.json composer.lock ./

# Install composer dependencies (without dev)
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer install --no-dev --no-scripts --optimize-autoloader --ignore-platform-reqs

# Now copy the rest of the app
COPY . .

# Run artisan scripts (after files are present)
RUN composer dump-autoload && php artisan key:generate --ansi || true

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html/storage

EXPOSE 80
CMD ["apache2-foreground"]
