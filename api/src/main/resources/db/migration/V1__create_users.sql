-- Usuários da API. O nome de usuário é salvo em minúsculas (normalizado pelo
-- AuthService), então o índice único já impede duplicatas como "Thorin" e
-- "thorin".
CREATE TABLE users (
    id            UUID         PRIMARY KEY,
    username      VARCHAR(30)  NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL
);

CREATE UNIQUE INDEX users_username_uq ON users (username);
