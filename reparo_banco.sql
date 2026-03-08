-- Roberto: Script de Diagnóstico e Reparo de Tabelas de Governança
-- Execute este script no Editor SQL do Supabase para destravar o Painel de Governança.

-- 1. Habilitar a extensão necessária para IDs únicos
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Garantir que a tabela 'equipe' exista com a estrutura correta
CREATE TABLE IF NOT EXISTS public.equipe (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT UNIQUE NOT NULL,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. Garantir que a tabela 'fluxo_etapas' exista com a estrutura correta
CREATE TABLE IF NOT EXISTS public.fluxo_etapas (
    id SERIAL PRIMARY KEY,
    fase TEXT NOT NULL,
    descricao TEXT UNIQUE NOT NULL,
    prazo_dias_uteis INTEGER NOT NULL,
    ordem INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. Inserir dados iniciais da equipe (se não existirem)
INSERT INTO public.equipe (nome) VALUES 
('Karla Oliveira'), ('Pedro'), ('Thiago'), ('Viviane'), ('Vivian'), ('Gorete Pereira')
ON CONFLICT (nome) DO NOTHING;

-- 5. Inserir o Fluxo Normativo solicitado pelo Pedro
INSERT INTO public.fluxo_etapas (ordem, fase, descricao, prazo_dias_uteis) VALUES
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
ON CONFLICT (descricao) DO NOTHING;

-- 6. Habilitar acesso público (RRL) para estas tabelas (Leitura e Escrita)
ALTER TABLE public.equipe ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total Equipe" ON public.equipe FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE public.fluxo_etapas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total Fluxo" ON public.fluxo_etapas FOR ALL USING (true) WITH CHECK (true);
