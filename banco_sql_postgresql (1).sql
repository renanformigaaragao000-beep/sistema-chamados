-- HELP DESK: banco relacional PostgreSQL
-- Execute este arquivo conectado ao banco de dados criado para o projeto.

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    telefone VARCHAR(30),
    tipo VARCHAR(20) NOT NULL DEFAULT 'solicitante'
        CHECK (tipo IN ('solicitante', 'tecnico', 'administrador')),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categorias (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao TEXT,
    ativa BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS chamados (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    solicitante_id BIGINT NOT NULL
        REFERENCES usuarios(id) ON DELETE RESTRICT,
    tecnico_responsavel_id BIGINT
        REFERENCES usuarios(id) ON DELETE SET NULL,
    categoria_id BIGINT NOT NULL
        REFERENCES categorias(id) ON DELETE RESTRICT,
    equipamento VARCHAR(120) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto'
        CHECK (status IN ('aberto', 'em_andamento', 'aguardando', 'resolvido', 'cancelado')),
    prioridade VARCHAR(10) NOT NULL DEFAULT 'media'
        CHECK (prioridade IN ('baixa', 'media', 'alta', 'urgente')),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolvido_em TIMESTAMPTZ,
    CHECK (resolvido_em IS NULL OR status = 'resolvido')
);

CREATE INDEX IF NOT EXISTS idx_chamados_solicitante ON chamados(solicitante_id);
CREATE INDEX IF NOT EXISTS idx_chamados_categoria ON chamados(categoria_id);
CREATE INDEX IF NOT EXISTS idx_chamados_status ON chamados(status);
CREATE INDEX IF NOT EXISTS idx_chamados_criado_em ON chamados(criado_em DESC);

-- Mantém atualizado_em correto sempre que um chamado for alterado.
CREATE OR REPLACE FUNCTION atualizar_data_chamado()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_atualizar_data_chamado ON chamados;
CREATE TRIGGER trg_atualizar_data_chamado
BEFORE UPDATE ON chamados
FOR EACH ROW
EXECUTE FUNCTION atualizar_data_chamado();

-- Categorias iniciais (não duplica registros se o script for executado novamente).
INSERT INTO categorias (nome, descricao) VALUES
    ('Hardware', 'Problemas físicos em computadores e periféricos.'),
    ('Software', 'Erros em programas, sistemas e aplicativos.'),
    ('Rede e Internet', 'Problemas de conexão e acesso à rede.'),
    ('Acesso e Senhas', 'Solicitações de acesso e redefinição de senha.'),
    ('Outros', 'Solicitações que não se enquadram nas demais categorias.')
ON CONFLICT (nome) DO NOTHING;

-- CONSULTAS ÚTEIS
-- Listar chamados com solicitante, categoria e técnico:
-- SELECT c.id, c.titulo, c.status, c.prioridade, u.nome AS solicitante,
--        cat.nome AS categoria, t.nome AS tecnico
-- FROM chamados c
-- JOIN usuarios u ON u.id = c.solicitante_id
-- JOIN categorias cat ON cat.id = c.categoria_id
-- LEFT JOIN usuarios t ON t.id = c.tecnico_responsavel_id
-- ORDER BY c.criado_em DESC;

-- Criar um chamado:
-- INSERT INTO chamados
-- (solicitante_id, categoria_id, equipamento, titulo, descricao)
-- VALUES (1, 1, 'Notebook', 'Computador não liga', 'O equipamento não inicia.');
