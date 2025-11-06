#!/bin/bash
date=$(date +"%Y-%m-%d_%H-%M-%S")
echo "Выполняется dump базы $POSTGRES_DB ..."
pg_dump -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /var/backups/db_dumps/${POSTGRES_DB}_${date}.sql
echo "Удаление бэкапов старше 10 минут"
find /var/backups/db_dumps -type f -mmin +10 -delete