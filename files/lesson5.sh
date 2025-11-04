#!/bin/bash

# Проверяем что контейнер БД запущен
if ! docker ps --format "table {{.Names}}" | grep -q "shvirtd-example-python-db-1"; then
    exit 1
fi

# Загружаем переменные из .env файла
set -a
source /home/jien/shvirtd-example-python/.env
set +a

# Настройка прав в БД
echo "Настраиваем права пользователя $MYSQL_USER в БД..."
docker exec shvirtd-example-python-db-1 mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';
FLUSH PRIVILEGES;
GRANT PROCESS ON *.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
"

# Создание бэкапа
echo "Создаем бэкап БД $MYSQL_DATABASE..."
docker run \
    --rm --entrypoint "" \
    -v /opt/backup:/backup \
    --network shvirtd-example-python_backend \
    schnitzler/mysqldump \
    mysqldump --opt -h db -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --result-file="/backup/dump-$(date +%s).sql" "$MYSQL_DATABASE"

echo "Бэкап сохранен в /opt/backup/"
