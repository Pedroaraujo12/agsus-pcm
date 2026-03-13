const SUPABASE_URL = "https://qakrpkwmhlpynrphucfl.supabase.co";
const SUPABASE_KEY = "sb_publishable_GO7Aqg_eNO6hqUIl3rAzyg_GRuiIkWE";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

class AgSUSApp {
    constructor() {
        this.data = [];
        this.tbody = document.getElementById('tableBody');
        this.loadFilters();
        this.init();
    }

    async init() {
        this.tbody.innerHTML = '<tr><td colspan="4" class="p-8 text-center text-slate-500 animate-pulse">Carregando dados...</td></tr>';
        const { data, error } = await sb.from('licitacoes').select('*');
        if (error) {
            this.tbody.innerHTML = '<tr><td colspan="4" class="p-8 text-center text-red-500">Erro ao carregar dados.</td></tr>';
            return;
        }
        this.data = data;
        this.render();
    }

    loadFilters() {
        const saved = localStorage.getItem('agsus_filters');
        if (saved) {
            // Restore filters logic
        }
    }

    saveFilters() {
        // Save filters logic
    }

    render() {
        this.tbody.innerHTML = '';
        if (this.data.length === 0) {
            this.tbody.innerHTML = '<tr><td colspan="4" class="p-8 text-center text-slate-500">Nenhum processo encontrado.</td></tr>';
            return;
        }

        let totalVlr = 0;
        this.data.forEach(item => {
            const vlr = parseFloat(item.vlr_estimado_anual) || 0;
            totalVlr += vlr;
            this.tbody.innerHTML += `
                <tr class="row-hover cursor-pointer" onclick="openDetails('${item.id_processo}')">
                    <td class="p-3 text-blue-400 font-bold">${item.id_processo}</td>
                    <td class="p-3 text-slate-300">
                        <div class="text-sm font-bold">${item.objeto_resumido || 'N/I'}</div>
                    </td>
                    <td class="p-3 text-center"><span class="bg-blue-900 text-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase">${item.status}</span></td>
                    <td class="p-3 text-right text-white font-mono">${vlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'})}</td>
                </tr>
            `;
        });
        document.getElementById('totalProcessos').innerText = this.data.length;
        document.getElementById('vlrEstimado').innerText = totalVlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'});
    }
}

document.addEventListener('DOMContentLoaded', () => new AgSUSApp());
