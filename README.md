# learning-repository
app.py и requirements:

```python
from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)


def get_db_connection():
    conn = psycopg2.connect(
        dbname="",
        user="postgres",
        password="postgres_password",
        host="db",
        port="&&"
    )
    return conn

@app.route('/')
def index():
    return 'TaskZilla API is running. Use /tasks endpoint.'

@app.route('/tasks', methods=['GET'])
def get_tasks():
    conn = get_db_connection()
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM tasks ORDER BY id;")
        tasks = cur.fetchall()
    conn.close()
    return jsonify(tasks)


@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.json
    description = data.get('description')
    status = data.get('status', 'в процессе')

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO tasks (description, status) VALUES (%s, %s) RETURNING id;",
            (description, status))
        task_id = cur.fetchone()[0]
        conn.commit()
    conn.close()
    return jsonify({"id": task_id, "description": description, "status": status}), 201

@app.route('/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    data = request.json
    description = data.get('description')
    status = data.get('status')

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE tasks SET description = %s, status = %s WHERE id = %s;",
            (description, status, task_id))
        conn.commit()
    conn.close()
    return jsonify({"id": task_id, "description": description, "status": status})

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("DELETE FROM tasks WHERE id = %s;", (task_id,))
        conn.commit()
    conn.close()
    return '', 204

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```


```
Flask==2.0.3
psycopg2-binary==2.9.6
Werkzeug==2.0.3
```

---

## DevOps-практика: Постгрес + Python API + автоматизация

## 1. Поднять PostgreSQL как отдельный сервис

- Установить PostgreSQL (любой способ: apt/yum/brew/официальный дистрибутив).
- Создать пользователя, БД tasksdb, задать пароль.
- Создать таблицу для задач:

  ```sql
  CREATE TABLE tasks (
      id SERIAL PRIMARY KEY,
      description TEXT NOT NULL,
      status VARCHAR(20) NOT NULL DEFAULT 'в процессе'
  );
  
  ```
- Запустить вручную API (вам даны файлы app.py и requirements.txt), запускать создав venv предварительно и установив нужные пакеты.
- Подключить API к локальной базе — изменить параметры подключения в app.py, чтобы host, user, password совпадали с вашим окружением.
- Протестировать с помощью curl:

  ```bash
  # Создать задачу
  curl -X POST -H "Content-Type: application/json" -d '{"description": "Сделать домашку", "status": "в процессе"}' http://localhost:*порт*/tasks
  
  # Просмотреть задачи
  curl http://localhost:*порт*/tasks
  
  #... самим через курл PUT запросом обновить какую нибудь задачу, приложить к отчету
  
  #... самим через curl удалить задачу, прикрепить к отчету
  ```

---

## 2. Перевести решение в контейнеры (Docker)

- Написать Dockerfile для API, собрать и проверить образ.
- Запустить PostgreSQL как отдельный контейнер (через docker run или docker-compose), убедиться в доступности порта.
- Реализовать инициализацию схемы (создание таблицы) с помощью файла init.sql (mount в /docker-entrypoint-initdb.d/).
- Собрать docker-compose файл для обоих сервисов (web и db), удостовериться, что они "видят" друг друга через сеть docker-compose (host для Python — 'db').
- Провести все те же тесты что и в прошлом задании

---

## 3. Организовать резервное копирование

- Написать bash-скрипт, который через интервал (например, через cron или простым sleep в bash) делает дампы базы (pg_dump) и кладёт их в отдельную папку.
- Обеспечить хранение нескольких последних бэкапов и автоматическую чистку старых.
- Проверить возможность восстановления БД из одного из бэкапов в случае потери данных:
  - Сделать дамп базы данных
  - Удалить все задачи через API
  - Восстановить данные из дампа
  - Проверить, что задачи вернулись

---

## 4. Дополнительные devops-задачи (по выбору)

- Реализовать автоматическое развёртывание через один скрипт (например, make start и make stop через Makefile).
- Добавить проверку жизни сервисов (healthcheck в компосте).