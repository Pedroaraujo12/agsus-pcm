-- Roberto: Script de Criação da Etapa Concluído e Lógica de Finalização
-- Execute este script no Editor SQL do Supabase.

-- 1. Inserir a Etapa 'Concluído' com SLA de 0 dias (fim de linha)
INSERT INTO public.fluxo_etapas (ordem, fase, descricao, prazo_dias_uteis) 
VALUES (99, 'Aprovação', 'Concluído', 0)
ON CONFLICT (descricao) DO UPDATE SET fase = 'Aprovação', ordem = 99, prazo_dias_uteis = 0;

-- 2. Atualizar o motor de SLA para lidar com processos concluídos
-- Se a fase for 'Concluído', o prazo não deve mais gerar alertas.
CREATE OR REPLACE FUNCTION calcular_data_prevista_sla() RETURNS TRIGGER AS $$
DECLARE dias_sla INTEGER;
BEGIN
    -- Se estiver Concluído, a data prevista é a própria data de hoje ou a data em que foi marcado
    IF NEW.fase_atual = 'Concluído' THEN
        NEW.status := 'Homologado';
        NEW.data_prevista := CURRENT_DATE;
        RETURN NEW;
    END IF;

    -- Busca o prazo da etapa atual no Admin
    SELECT prazo_dias_uteis INTO dias_sla FROM fluxo_etapas WHERE descricao = NEW.fase_atual;
    
    -- Se não houver etapa definida, assume 5 dias como segurança
    IF dias_sla IS NULL THEN dias_sla := 5; END IF;
    
    -- Se não houver data de recebimento, usa a data de entrada ou a atual
    IF NEW.data_recebimento IS NULL THEN 
        NEW.data_recebimento := COALESCE(NEW.data_entrada::DATE, CURRENT_DATE); 
    END IF;
    
    -- Calcula a nova data prevista usando a função de dias úteis
    NEW.data_prevista := public.data_rece_calc(NEW.data_recebimento, dias_sla);
    
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
