-- SQL para Estrutura Final AgSUS PCM SaaS (v12)
-- Execute este script no SQL Editor do seu Supabase para ativar todos os módulos.

-- 1. EXTENSÕES E SEGURANÇA
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABELA DE PROCESSOS (CORE)
-- Esta tabela já existe (licitacoes), vamos apenas garantir que ela tenha os campos necessários.
-- Se a tabela já existir, o Supabase ignorará o comando ou você pode adicionar colunas via ALTER.
CREATE TABLE IF NOT EXISTS licitacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    id_processo TEXT UNIQUE NOT NULL,
    objeto_resumido TEXT,
    demandante TEXT,
    modalidade TEXT,
    prioridade TEXT,
    fase_atual TEXT DEFAULT 'Abertura',
    status TEXT DEFAULT 'Em andamento',
    coordenacao TEXT DEFAULT 'CCS.RD',
    vlr_estimado_anual DECIMAL DEFAULT 0,
    vlr_homologado DECIMAL DEFAULT 0,
    data_entrada DATE DEFAULT CURRENT_DATE,
    data_prevista DATE, -- Prazo da Tarefa Atual
    observacoes TEXT,
    processo_link TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABELA DE FORNECEDORES (SRM)
CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cnpj TEXT UNIQUE NOT NULL,
    razao_social TEXT NOT NULL,
    nome_fantasia TEXT,
    categoria TEXT, -- Ex: Saúde, TI, Mobiliário
    contato_email TEXT,
    status_cnd BOOLEAN DEFAULT true,
    rating DECIMAL DEFAULT 5.0,
    historico_penalidades TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABELA DE PROPOSTAS (JULGAMENTO)
CREATE TABLE IF NOT EXISTS propostas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    processo_id TEXT REFERENCES licitacoes(id_processo) ON DELETE CASCADE,
    fornecedor_id UUID REFERENCES fornecedores(id),
    valor_proposta DECIMAL NOT NULL,
    status_julgamento TEXT DEFAULT 'Classificado', -- Vencedor, Desclassificado, Classificado
    data_lance TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABELA DE CONTRATOS E ADITIVOS
CREATE TABLE IF NOT EXISTS contratos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    numero_contrato TEXT UNIQUE NOT NULL,
    processo_id TEXT REFERENCES licitacoes(id_processo),
    fornecedor_id UUID REFERENCES fornecedores(id),
    valor_global DECIMAL NOT NULL,
    data_assinatura DATE,
    data_vencimento DATE,
    status_contratual TEXT DEFAULT 'Ativo',
    fiscal_nome TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contrato_alteracoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contrato_id UUID REFERENCES contratos(id),
    tipo_alteracao TEXT NOT NULL, -- Aditivo, Apostilamento, Supressão, Reequilíbrio
    valor_alteracao DECIMAL DEFAULT 0,
    nova_data_vencimento DATE,
    justificativa TEXT,
    data_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. TABELA DE ALMOXARIFADO VIRTUAL (SALDOS)
CREATE TABLE IF NOT EXISTS itens_ata (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    processo_id TEXT REFERENCES licitacoes(id_processo),
    descricao_item TEXT NOT NULL,
    catmat TEXT,
    qtd_total DECIMAL NOT NULL,
    qtd_consumida DECIMAL DEFAULT 0,
    valor_unitario DECIMAL NOT NULL,
    unidade_medida TEXT DEFAULT 'UN'
);

CREATE TABLE IF NOT EXISTS requisicoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    item_id UUID REFERENCES itens_ata(id),
    area_demandante TEXT NOT NULL,
    municipio_destino TEXT,
    qtd_solicitada DECIMAL NOT NULL,
    status_aprovacao TEXT DEFAULT 'Pendente', -- Pendente, Aprovado, Rejeitado, Entregue
    data_solicitacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    aprovado_por TEXT
);

-- 7. TABELA DE PAGAMENTOS
CREATE TABLE IF NOT EXISTS pagamentos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contrato_id UUID REFERENCES contratos(id),
    numero_nota_fiscal TEXT NOT NULL,
    valor_liquido DECIMAL NOT NULL,
    data_emissao DATE,
    status_liquidacao TEXT DEFAULT 'Entrada', -- Entrada, Ateste, Liquidado, Pago
    link_nota TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- HABILITAR RLS (Segurança básica para o protótipo - Permite leitura e escrita pública para testes)
-- Em produção, restringiremos ao seu usuário logado.
ALTER TABLE licitacoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Público Testes" ON licitacoes FOR ALL USING (true) WITH CHECK (true);
-- Repetir para as outras tabelas se necessário, mas por padrão vamos deixar aberto para seu teste inicial.
