#!/bin/sh
set -e

# Свежий клон: vendor ставится при первом старте php-fpm. Остальные контейнеры на этом образе
# (очередь, команды) запускают свою команду как есть — и не ставят vendor параллельно.
if [ "$1" = "php-fpm" ] && [ -f composer.json ] && [ ! -d vendor ]; then
    composer install --no-interaction --no-progress
fi

exec "$@"
