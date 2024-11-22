#!/bin/bash

chown -R www-data:www-data /var/www/html
find /var/www/html -type f -exec chmod 664 {} \;
find /var/www/html -type d -exec chmod 775 {} \;

chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

mkdir -p /var/www/html/storage/framework/{sessions,views,cache}
mkdir -p /var/www/html/storage/logs

chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

if [ ! -d "/var/www/html/vendor" ] || [ ! "$(ls -A /var/www/html/vendor)" ]; then
    composer install --no-interaction --optimize-autoloader
fi

if [ -z "$APP_KEY" ]; then
    php artisan key:generate
fi

php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

php-fpm -D
nginx -g "daemon off;"