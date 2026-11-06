# nginx перед PHP-FPM для локальной разработки: сервис PHP в docker-compose.yml сайта называется php-fpm.
FROM nginx:stable-alpine

LABEL org.opencontainers.image.source="https://github.com/zuberkz/laravel-docker" \
      org.opencontainers.image.description="nginx для локальной разработки Laravel-сайтов студии" \
      org.opencontainers.image.licenses="MIT"

COPY default.conf /etc/nginx/conf.d/default.conf
