# Use PHP with Composer preinstalled
FROM composer:2.7 AS build

WORKDIR /app

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the app
COPY . .

# Install Node and build assets (optional)
RUN apt-get update && apt-get install -y nodejs npm
RUN npm install && npm run build

# -------------------------
# Stage 2: Production Image
# -------------------------
FROM php:8.2-apache

# Enable Apache rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copy from build stage
COPY --from=build /app ./

# Copy Laravel .env (Render injects env automatically)
COPY .env.example .env

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
