# laravel-docker

Локальное Docker-окружение Laravel-сайтов студии: образы PHP-FPM и nginx в GitHub Container
Registry. **Только для разработки** — на хостинге сайты работают в ISPmanager с системным PHP, без
Docker. Образ повторяет сервер (версия PHP, расширения, лимиты загрузки, https), чтобы локально
не работало то, что упадёт на сервере, и наоборот.

| Образ | Что внутри |
|-------|------------|
| `ghcr.io/zuberkz/laravel-php:8.5` | PHP-FPM на Alpine: bcmath, exif, gd, intl, pcntl, pdo_mysql, pdo_pgsql, zip, opcache, Xdebug (выключен), composer, git; процессы от uid 1000 |
| `ghcr.io/zuberkz/laravel-nginx:latest` | nginx: фронт-контроллер Laravel, загрузки до 10 МБ, `HTTPS=on` за https-прокси OrbStack |

Образы собираются под amd64 и arm64 (Mac) при каждом пуше в `main` и раз в неделю — с
обновлениями безопасности базовых образов. Перед публикацией каждый образ проверяется: расширения,
версия PHP, лимиты, `php-fpm -t`, `nginx -t`.

## Сайт

`docker-compose.yml` (так в laravel-starter):

```yaml
services:
    php-fpm:
        image: ghcr.io/zuberkz/laravel-php:8.5
        restart: unless-stopped
        volumes:
            - ./:/var/www/html
        depends_on:
            mariadb:
                condition: service_healthy

    nginx:
        image: ghcr.io/zuberkz/laravel-nginx:latest
        restart: unless-stopped
        depends_on:
            - php-fpm
        volumes:
            - ./:/var/www/html
```

- Сервис PHP называется `php-fpm` — на это имя смотрит nginx.
- Свежий клон: при первом старте `php-fpm` сам выполнит `composer install`, если нет `vendor`.
- Обновить образы: `docker compose pull && docker compose up -d`.
- Команды — `docker compose exec php-fpm php artisan …`; они идут от uid 1000, как и PHP-FPM, поэтому
  у файлов в `storage` и `vendor` один владелец.

## Дополнить в одном проекте

Что нужно двум проектам и больше — переносится сюда, в общий образ.

**Настройка PHP** — свой ini поверх общего:

```yaml
php-fpm:
    volumes:
        - ./:/var/www/html
        - ./.docker/php.ini:/usr/local/etc/php/conf.d/zzz-site.ini:ro
```

**Расширение или системный пакет** — свой Dockerfile от общего образа, в compose `build` вместо
`image`:

```dockerfile
# .docker/php/Dockerfile
FROM ghcr.io/zuberkz/laravel-php:8.5
USER root
RUN install-php-extensions imagick redis
USER app
```

```yaml
php-fpm:
    build:
        context: .docker/php
        pull: true
```

**Своя настройка nginx** — свой конфиг вместо общего:

```yaml
nginx:
    volumes:
        - ./:/var/www/html
        - ./.docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
```

**Xdebug** — в `docker-compose.override.yml` (не коммитится):

```yaml
services:
    php-fpm:
        environment:
            XDEBUG_MODE: debug
```

Для одной команды: `docker compose exec -e XDEBUG_MODE=debug php-fpm php artisan …`. Порт 9003,
запуск по триггеру (расширение браузера или `XDEBUG_TRIGGER`).

## Изменить образ

Правка в `php/` или `nginx/`, пуш в `main` — workflow соберёт, проверит и опубликует. Локально
проверить до пуша:

```sh
docker build -t ghcr.io/zuberkz/laravel-php:8.5 php
docker build -t ghcr.io/zuberkz/laravel-nginx:latest nginx
```

Только PHP 8.5 — на нём сайты студии и сервер. Другая версия (например, 8.6 при переходе) — строка в
матрицах `build` и `merge` в `.github/workflows/build.yml`.
