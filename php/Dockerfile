# PHP-FPM для локальной разработки студийных Laravel-сайтов. Прод — ISPmanager с системным PHP, без
# Docker: образ повторяет сервер (версия PHP, расширения, лимиты), чтобы локально не работало то, что
# упадёт на сервере, и наоборот.
ARG PHP_VERSION=8.5

FROM php:${PHP_VERSION}-fpm-alpine

LABEL org.opencontainers.image.source="https://github.com/zuberkz/laravel-docker" \
      org.opencontainers.image.description="PHP-FPM для локальной разработки Laravel-сайтов студии" \
      org.opencontainers.image.licenses="MIT"

# install-php-extensions сам ставит и удаляет системные зависимости расширений
COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# git и unzip нужны composer; opcache встроен в ядро только с PHP 8.5
RUN apk add --no-cache git unzip \
    && install-php-extensions bcmath exif gd intl pcntl pdo_mysql pdo_pgsql zip xdebug \
    && (php -m | grep -q 'Zend OPcache' || install-php-extensions opcache)

COPY conf/php.ini /usr/local/etc/php/conf.d/zz-studio.ini
COPY conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY conf/www.conf /usr/local/etc/php-fpm.d/zz-studio.conf
COPY --chmod=755 entrypoint.sh /usr/local/bin/studio-entrypoint

# Процессы работают от uid 1000, как пользователь macOS: файлы, которые создают artisan и composer
# (кэш, логи, vendor), принадлежат ему, а не root. Без root директивы user/group пула не нужны.
RUN addgroup -g 1000 app \
    && adduser -D -G app -u 1000 app \
    && sed -i -e '/^user = /d' -e '/^group = /d' /usr/local/etc/php-fpm.d/www.conf

USER app
WORKDIR /var/www/html

ENTRYPOINT ["studio-entrypoint"]
CMD ["php-fpm"]
