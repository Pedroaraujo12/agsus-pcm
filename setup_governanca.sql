-- Script de Criação das Tabelas de Apoio para Governança AgSUS PCM

-- 1. Tabela de Equipe (Responsáveis)
CREATE TABLE IF NOT EXISTS equipe (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT UNIQUE NOT NULL,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Tabela de Fluxo Normativo (Fases e SLAs)
CREATE TABLE IF NOT EXISTS fluxo_etapas (
    id SERIAL PRIMARY KEY,
    fase TEXT NOT NULL, -- Ex: Planejamento, Produção, Execução
    descricao TEXT UNIQUE NOT NULL, -- Descrição da Atividade
    prazo_dias_uteis INTEGER NOT NULL,
    ordem INTEGER NOT NULL,
    cor_referencia TEXT DEFAULT '#3b82f6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. Inserção das Etapas Normativas (Baseado na solicitação do Pedro)
INSERT INTO fluxo_etapas (ordem, fase, descricao, prazo_dias_uteis) VALUES
(1, 'Planejamento', 'Análise do Termo de Referência e anexos', 3),
(2, 'Produção', 'Pesquisa de Preços e levantamento do custo estimado', 5),
(3, 'Produção', 'Relatório de Pesquisa Preços Análise Disponibilidade orçamentária', 1),
(4, 'Revisão', 'Designação da Comissão de Seleção', 1),
(5, 'Produção', 'Elaboração Da Minuta de Edital e Anexos. Envio à UJUR', 5),
(6, 'Análise', 'Análise jurídica e Emissão de Parecer', 5),
(7, 'Produção', 'Adequações ao Parecer Jurídico e Autorização Governança', 1),
(8, 'Produção', 'Publicação do Edital (Prazos Legais)', 8),
(9, 'Execução', 'Abertura e Fase de Lances', 1),
(10, 'Execução', 'Fase de Julgamento, Aceitação e Habilitação', 8),
(11, 'Execução', 'Envio da proposta para análise da área demandante', 1),
(12, 'Análise', 'Resposta da Área demandante', 1),
(13, 'Análise', 'Prazo recursal (3 DIAS ÚTEIS)', 3),
(14, 'Aprovação', 'Prazo contrarrazões (3 DIAS ÚTEIS)', 3),
(15, 'Aprovação', 'Decisão quanto ao recurso (5 dias úteis)', 5),
(16, 'Aprovação', 'Envio do Recurso ao Jurídico e Ratificação', 2)
ON CONFLICT (descricao) DO UPDATE SET prazo_dias_uteis = EXCLUDED.prazo_dias_uteis, ordem = EXCLUDED.ordem;

-- 4. Inserção Inicial da Equipe
INSERT INTO equipe (nome) VALUES 
('Karla Oliveira'), ('Pedro'), ('Thiago'), ('Viviane'), ('Vivian'), ('Gorete Pereira')
ON CONFLICT (nome) DO NOTHING;
