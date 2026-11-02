FROM php:8.4.27-cli
COPY --from=composer:2.11.1 /usr/bin/composer /usr/bin/composer
RUN apt-get update && apt-get install -y --no-install-recommends git unzip \
 && pecl install xdebug-3.5.3 pcov-1.0.12 && rm -rf /var/lib/apt/lists/* /tmp/pear
