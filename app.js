const SUPABASE_URL = "https://qakrpkwmhlpynrphucfl.supabase.co";
const SUPABASE_KEY = "sb_publishable_GO7Aqg_eNO6hqUIl3rAzyg_GRuiIkWE";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

class AgSUSApp {
    constructor() {
        this.data = [];
        this.tbody = document.getElementById('tableBody');
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
        
        // Popular filtro de status
        const statuses = [...new Set(data.map(i => i.status))];
        statuses.forEach(s => this.statusFilter.innerHTML += `<option value="${s}">${s}</option>`);
        
        this.render();
    }

    render() {
        const searchTerm = this.search.value.toLowerCase();
        const statusTerm = this.statusFilter.value;
        
        const filtered = this.data.filter(item => {
            const matchesSearch = (item.id_processo || '').toLowerCase().includes(searchTerm);
            const matchesStatus = (statusTerm === 'Todos' || item.status === statusTerm);
            return matchesSearch && matchesStatus;
        });

        this.tbody.innerHTML = '';
        let totalVlr = 0;
        
        filtered.forEach(item => {
            const vlr = parseFloat(item.vlr_estimado_anual) || 0;
            totalVlr += vlr;
            this.tbody.innerHTML += `
                <tr class="row-hover cursor-pointer" onclick="openDetails('${item.id_processo}')">
                    <td class="p-3 text-blue-400 font-bold">${item.id_processo}</td>
                    <td class="p-3 text-slate-300">${item.objeto_resumido || 'N/I'}</td>
                    <td class="p-3"><span class="bg-blue-900 text-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase">${item.status}</span></td>
                    <td class="p-3 text-right text-white font-mono">${vlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'})}</td>
                </tr>
            `;
        });
        
        document.getElementById('totalProcessos').innerText = filtered.length;
        document.getElementById('vlrEstimado').innerText = totalVlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'});
    }
}

document.addEventListener('DOMContentLoaded', () => new AgSUSApp());
