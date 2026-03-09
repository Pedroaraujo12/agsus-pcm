-- SQL Master Performance & Integrity Update
-- AgSUS PCM SaaS - Auditoria de TI (Março 2026)

-- 1. Criação de Índices de Busca (Performance P2)
-- Otimiza filtros de Status, Responsável e buscas por ID de Processo
CREATE INDEX IF NOT EXISTS idx_licitacoes_status ON licitacoes (status);
CREATE INDEX IF NOT EXISTS idx_licitacoes_responsavel ON licitacoes (responsavel);
CREATE INDEX IF NOT EXISTS idx_licitacoes_id_processo ON licitacoes (id_processo);
CREATE INDEX IF NOT EXISTS idx_licitacoes_fase_atual ON licitacoes (fase_atual);

-- 2. Índice Composto para o Painel Operacional
-- Acelera a query principal que combina ID, Status e Responsável
CREATE INDEX IF NOT EXISTS idx_dashboard_lookup ON licitacoes (id_processo, status, responsavel);

-- 3. Reforço de Integridade (Constraints)
-- Garante que não existam IDs de processo vazios e que sejam únicos
ALTER TABLE licitacoes ALTER COLUMN id_processo SET NOT NULL;
-- Nota: Caso existam duplicatas, o comando abaixo falhará. Recomenda-se limpeza manual prévia.
-- ALTER TABLE licitacoes ADD CONSTRAINT unique_processo UNIQUE (id_processo);

-- 4. Otimização de Tabelas de Apoio
CREATE INDEX IF NOT EXISTS idx_fluxo_etapas_ordem ON fluxo_etapas (ordem);
CREATE INDEX IF NOT EXISTS idx_equipe_nome ON equipe (nome);

ANALYZE licitacoes;
ANALYZE fluxo_etapas;
ANALYZE equipe;
