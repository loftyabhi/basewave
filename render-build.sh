#!/usr/bin/env bash
# exit on error
set -o errexit

# Install PHP dependencies
composer install --no-dev --optimize-autoloader

# Generate Ziggy routes (optional but fixes missing vendor files)
php artisan ziggy:generate resources/js/ziggy.js || true

# Install Node dependencies and build assets
npm ci
npm run build

# Clear and cache Laravel config/routes/views
php artisan config:cache
php artisan route:cache
php artisan view:cache
