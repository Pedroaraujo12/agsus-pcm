-- Roberto: Script de Atualização para Contagem de Prazos SLA
-- Execute este script no Editor SQL do Supabase.

-- 1. Adicionar a coluna data_recebimento se ela não existir
ALTER TABLE public.licitacoes 
ADD COLUMN IF NOT EXISTS data_recebimento DATE;

-- 2. Migrar dados: Para processos antigos, assumir data_recebimento = data_entrada
UPDATE public.licitacoes 
SET data_recebimento = data_entrada 
WHERE data_recebimento IS NULL AND data_entrada IS NOT NULL;

-- 3. Criar uma função para calcular a data prevista (SLA) baseada em dias úteis
-- Esta função soma os dias úteis da etapa atual à data de recebimento
CREATE OR REPLACE FUNCTION calcular_data_prevista_sla()
RETURNS TRIGGER AS $$
DECLARE
    dias_sla INTEGER;
BEGIN
    -- Busca o prazo em dias úteis da etapa atual cadastrada no Admin
    SELECT prazo_dias_uteis INTO dias_sla 
    FROM fluxo_etapas 
    WHERE descricao = NEW.fase_atual;

    -- Se não encontrar a etapa ou prazo, assume 5 dias como fallback
    IF dias_sla IS NULL THEN
        dias_sla := 5;
    END IF;

    -- Cálculo simples de data prevista (Data Recebimento + Dias SLA)
    -- Nota: Uma lógica de dias úteis real (pulando fins de semana) exigiria uma tabela de calendário,
    -- por enquanto usaremos a soma direta para ativar a funcionalidade.
    NEW.data_prevista := (NEW.data_recebimento + (dias_sla || ' days')::interval)::date;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Trigger para atualizar automaticamente a data_prevista ao inserir ou editar
DROP TRIGGER IF EXISTS tr_atualiza_sla ON public.licitacoes;
CREATE TRIGGER tr_atualiza_sla
BEFORE INSERT OR UPDATE OF fase_atual, data_recebimento ON public.licitacoes
FOR EACH ROW EXECUTE FUNCTION calcular_data_prevista_sla();
