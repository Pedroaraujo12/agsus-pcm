CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABELA DE EQUIPE
CREATE TABLE IF NOT EXISTS public.equipe (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT UNIQUE NOT NULL,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. TABELA DE FLUXO E PRAZOS
CREATE TABLE IF NOT EXISTS public.fluxo_etapas (
    id SERIAL PRIMARY KEY,
    fase TEXT NOT NULL,
    descricao TEXT UNIQUE NOT NULL,
    prazo_dias_uteis INTEGER NOT NULL,
    ordem INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. DADOS INICIAIS DA EQUIPE
INSERT INTO public.equipe (nome) VALUES 
('Karla Oliveira'), ('Pedro'), ('Thiago'), ('Viviane'), ('Vivian'), ('Gorete Pereira')
ON CONFLICT (nome) DO NOTHING;

-- 4. ETAPAS CDA 23/2025 E PRAZOS
INSERT INTO public.fluxo_etapas (ordem, fase, descricao, prazo_dias_uteis) VALUES
(1, 'Planejamento', 'Análise do Termo de Referência e anexos', 3),
(2, 'Produção', 'Pesquisa de Preços e levantamento do custo estimado', 5),
(3, 'Produção', 'Relatório de Pesquisa Preços Análise Disponibilidade orçamentária', 1),
(4, 'Revisão', 'Designação da Comissão de Seleção', 1),
(5, 'Produção', 'Elaboração Da Minuta de Edital e Anexos. Envio à UJUR', 5),
(6, 'Análise', 'Análise jurídica e Emissão de Parecer', 5),
(7, 'Produção', 'Adequações e atendimento ao Parecer Jurídico', 1),
(8, 'Produção', 'Publicação do Edital (Prazos Legais PNCP)', 8),
(9, 'Execução', 'Abertura e Fase de Lances', 1),
(10, 'Execução', 'Fase de Julgamento, Aceitação e Habilitação', 8),
(11, 'Execução', 'Envio da proposta para análise da área demandante', 1),
(12, 'Análise', 'Resposta da Área demandante', 1),
(13, 'Análise', 'Prazo recursal (3 DIAS ÚTEIS)', 3),
(14, 'Aprovação', 'Prazo contrarrazões (3 DIAS ÚTEIS)', 3),
(15, 'Aprovação', 'Decisão quanto ao recurso (5 dias úteis)', 5),
(16, 'Aprovação', 'Envio do Recurso ao Jurídico e Ratificação', 2)
ON CONFLICT (descricao) DO NOTHING;

-- 5. LIBERAÇÃO DE ACESSO (POLÍTICAS DE SEGURANÇA)
ALTER TABLE public.equipe ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Acesso Total Equipe" ON public.equipe;
CREATE POLICY "Acesso Total Equipe" ON public.equipe FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE public.fluxo_etapas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Acesso Total Fluxo" ON public.fluxo_etapas;
CREATE POLICY "Acesso Total Fluxo" ON public.fluxo_etapas FOR ALL USING (true) WITH CHECK (true);

-- 6. PUBLICAR NO SCHEMA PARA A API RECONHECER
GRANT ALL ON public.equipe TO anon;
GRANT ALL ON public.equipe TO authenticated;
GRANT ALL ON public.fluxo_etapas TO anon;
GRANT ALL ON public.fluxo_etapas TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
