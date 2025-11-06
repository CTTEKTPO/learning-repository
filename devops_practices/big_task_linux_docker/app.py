from flask import Flask, request, jsonify,json
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = Flask(__name__)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'database': os.getenv('DB_NAME', 'tasksdb'),
    'user': os.getenv('DB_USER', 'tasksuser'),
    'password': os.getenv('DB_PASSWORD', 'secret_passwd'),
    'port': int(os.getenv('DB_PORT', 5432))
}

def get_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Ошибка подключения к БД: {e}")
        return None

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