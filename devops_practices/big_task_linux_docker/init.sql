CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'в процессе'
);
INSERT INTO tasks (description, status) VALUES ('Купить хлеб', 'в процессе');
INSERT INTO tasks (description, status) VALUES ('Написать диплом', 'завершена');
INSERT INTO tasks (description, status) VALUES ('Позвонить врачу', 'ожидает');