FROM composer:2.5 as vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-suggest

# Laravel con NGINX + PHP-FPM + Node
FROM php:8.2-fpm

WORKDIR /var/www/html

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    npm \
    nodejs \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Copiar dependencias de Composer
COPY --from=vendor /app /var/www/html

# Copiar código
COPY . .

# Generar assets con Vite
RUN npm install && npm run build

# Dar permisos
RUN chmod -R 755 /var/www/html/storage

# Exponer puerto para PHP
EXPOSE 8000

# Comando final
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
