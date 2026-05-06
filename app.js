const SUPABASE_URL = "https://qakrpkwmhlpynrphucfl.supabase.co";
const SUPABASE_KEY = "sb_publishable_GO7Aqg_eNO6hqUIl3rAzyg_GRuiIkWE";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const ETAPAS = [
    { ordem: 1, descricao: "Análise do Termo de Referência e anexos" },
    { ordem: 2, descricao: "Pesquisa de Preços e levantamento do custo estimado" },
    { ordem: 3, descricao: "Relatório de Pesquisa Preços Análise Disponibilidade orçamentária" },
    { ordem: 4, descricao: "Designação da Comissão de Seleção" },
    { ordem: 5, descricao: "Elaboração Da Minuta de Edital e Anexos. Envio à UJUR" },
    { ordem: 6, descricao: "Análise jurídica e Emissão de Parecer" },
    { ordem: 7, descricao: "Adequações e atendimento ao Parecer Jurídico" },
    { ordem: 8, descricao: "Publicação do Edital (Prazos Legais PNCP)" },
    { ordem: 9, descricao: "Abertura e Fase de Lances" },
    { ordem: 10, descricao: "Fase de Julgamento, Aceitação e Habilitação" },
    { ordem: 11, descricao: "Envio da proposta para análise da área demandante" },
    { ordem: 12, descricao: "Resposta da Área demandante" },
    { ordem: 13, descricao: "Prazo recursal (3 DIAS ÚTEIS)" },
    { ordem: 14, descricao: "Prazo contrarrazões (3 DIAS ÚTEIS)" },
    { ordem: 15, descricao: "Decisão quanto ao recurso (5 dias úteis)" },
    { ordem: 16, descricao: "Envio do Recurso ao Jurídico e Ratificação" },
    { ordem: 99, descricao: "Concluído" }
];

class AgSUSApp {
    constructor() {
        this.data = [];
        this.tbody = document.getElementById('tableBody');
        this.cardContainer = document.getElementById('cardContainer');
        this.search = document.getElementById('search');
        this.statusFilter = document.getElementById('statusFilter');
        
        this.search.addEventListener('input', () => this.render());
        this.statusFilter.addEventListener('change', () => this.render());
        
        this.init();
    }

    async init() {
        const { data, error } = await sb.from('licitacoes').select('*');
        if (error) return;
        this.data = data;
        
        const statuses = [...new Set(data.map(i => i.status))];
        statuses.forEach(s => this.statusFilter.innerHTML += `<option value="${s}">${s}</option>`);
        
        this.render();
    }

    formatDate(dateStr) {
        if (!dateStr) return '--';
        try {
            return new Date(dateStr).toLocaleDateString('pt-BR');
        } catch {
            return dateStr;
        }
    }

    render() {
        const searchTerm = this.search.value.toLowerCase();
        const statusTerm = this.statusFilter.value;
        
        const filtered = this.data.filter(item => {
            const matchesSearch = (item.id_processo || '').toLowerCase().includes(searchTerm) || (item.objeto_resumido || '').toLowerCase().includes(searchTerm);
            const matchesStatus = (statusTerm === 'Todos' || item.status === statusTerm);
            return matchesSearch && matchesStatus;
        });

        this.tbody.innerHTML = '';
        if (this.cardContainer) this.cardContainer.innerHTML = '';
        let totalVlr = 0;
        
        filtered.forEach(item => {
            const vlr = parseFloat(item.vlr_estimado_anual) || 0;
            totalVlr += vlr;
            
            const etapa = ETAPAS.find(e => e.descricao === item.fase_atual) || { ordem: 0 };
            const percent = Math.min((etapa.ordem / 17) * 100, 100);
            const atividadeAtual = item.fase_atual || '--';
            const dadosAtividade = this.formatDate(item.data_prevista);

            this.tbody.innerHTML += `
                <tr class="row-hover cursor-pointer" onclick="openDetails('${item.id_processo}')">
                    <td class="p-3 text-blue-400 font-bold">${item.id_processo}</td>
                    <td class="p-3 text-slate-300">
                        <div class="text-sm font-bold">${item.objeto_resumido || 'N/I'}</div>
                        <div class="w-full bg-slate-800 h-1 mt-1 rounded-full overflow-hidden">
                            <div class="bg-blue-600 h-full" style="width: ${percent}%"></div>
                        </div>
                    </td>
                    <td class="p-3 text-slate-300 text-xs">${atividadeAtual}</td>
                    <td class="p-3 text-slate-400 text-xs font-mono">${dadosAtividade}</td>
                </tr>
            `;

            if (this.cardContainer) {
                this.cardContainer.innerHTML += `
                    <div class="glass-card p-5 border border-border">
                        <div class="flex justify-between items-start mb-3">
                            <span class="text-blue-400 font-bold text-sm">${item.id_processo}</span>
                            <span class="bg-blue-900/50 text-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase">${item.status || '--'}</span>
                        </div>
                        <p class="text-xs text-slate-400 mb-2">${item.objeto_resumido || 'N/I'}</p>
                        <p class="text-xs text-slate-500 mb-1"><span class="font-bold text-slate-400">Atividade:</span> ${atividadeAtual}</p>
                        <p class="text-xs text-slate-500"><span class="font-bold text-slate-400">Data:</span> ${dadosAtividade}</p>
                    </div>
                `;
            }
        });
        
        document.getElementById('totalProcessos').innerText = filtered.length;
        document.getElementById('vlrEstimado').innerText = totalVlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'});
    }
}

document.addEventListener('DOMContentLoaded', () => new AgSUSApp());
