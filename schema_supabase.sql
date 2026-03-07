-- SQL Inicial para Estrutura AgSUS PCM SaaS

-- 1. Tabela de Perfis de Usuário (Controle de Acesso)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  email TEXT UNIQUE,
  role TEXT CHECK (role IN ('admin', 'tecnico', 'demandante', 'visualizador')) DEFAULT 'visualizador',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Tabela de Fornecedores (SRM)
CREATE TABLE IF NOT EXISTS fornecedores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cnpj TEXT UNIQUE NOT NULL,
  razao_social TEXT NOT NULL,
  nome_fantasia TEXT,
  contato_nome TEXT,
  contato_email TEXT,
  status_cnd BOOLEAN DEFAULT true,
  rating DECIMAL DEFAULT 5.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. Tabela de Contratos (Gestão 360º)
CREATE TABLE IF NOT EXISTS contratos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  numero_contrato TEXT UNIQUE,
  id_processo_origem TEXT,
  fornecedor_id UUID REFERENCES fornecedores(id),
  objeto TEXT,
  valor_global DECIMAL NOT NULL,
  data_assinatura DATE,
  data_vencimento DATE,
  status TEXT DEFAULT 'ativo',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. Tabela de Itens (Almoxarifado Virtual)
CREATE TABLE IF NOT EXISTS itens_almoxarifado (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  contrato_id UUID REFERENCES contratos(id),
  descricao TEXT NOT NULL,
  catmat TEXT,
  qtd_total DECIMAL NOT NULL,
  qtd_consumida DECIMAL DEFAULT 0,
  valor_unitario DECIMAL NOT NULL,
  unidade_medida TEXT
);

-- 5. Tabela de Requisições (Workflow Demandante)
CREATE TABLE IF NOT EXISTS requisicoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  item_id UUID REFERENCES itens_almoxarifado(id),
  demandante_id UUID REFERENCES profiles(id),
  qtd_solicitada DECIMAL NOT NULL,
  status TEXT CHECK (status IN ('pendente', 'aprovada', 'rejeitada', 'entregue')) DEFAULT 'pendente',
  data_solicitacao TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  aprovado_por UUID REFERENCES profiles(id)
);
