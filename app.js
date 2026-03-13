const SUPABASE_URL = "https://qakrpkwmhlpynrphucfl.supabase.co";
const SUPABASE_KEY = "sb_publishable_GO7Aqg_eNO6hqUIl3rAzyg_GRuiIkWE";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const SLAS = { 'Pregão Eletrônico': 52, 'Cotação de Preços': 20, 'Concorrência': 65, 'Dispensa de Licitação': 15 };

class AgSUSApp {
    constructor() {
        this.data = [];
        this.tbody = document.getElementById('tableBody');
        this.search = document.getElementById('search');
        this.statusFilter = document.getElementById('statusFilter');
        this.charts = {};
        
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

    // Engine de Dias Úteis (Fix master)
    isHoliday(date) {
        const holidays = ['01-01', '04-21', '05-01', '09-07', '10-12', '11-02', '11-15', '11-20', '12-25'];
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        return holidays.includes(`${m}-${d}`);
    }

    getBusinessDaysDiff(startDate, endDate) {
        let count = 0;
        let cur = new Date(startDate.getTime());
        let target = new Date(endDate.getTime());
        const isNegative = target < cur;
        while (isNegative ? cur > target : cur < target) {
            isNegative ? cur.setDate(cur.getDate() - 1) : cur.setDate(cur.getDate() + 1);
            if (cur.getDay() !== 0 && cur.getDay() !== 6 && !this.isHoliday(cur)) isNegative ? count-- : count++;
        }
        return count;
    }

    render() {
        const filtered = this.data.filter(item => {
            const matchesSearch = (item.id_processo || '').toLowerCase().includes(this.search.value.toLowerCase());
            const matchesStatus = (this.statusFilter.value === 'Todos' || item.status === this.statusFilter.value);
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
                    <td class="p-3"><span class="bg-blue-900/50 text-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase">${item.status}</span></td>
                    <td class="p-3 text-right text-white font-mono">${vlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'})}</td>
                </tr>
            `;
        });
        
        document.getElementById('totalProcessos').innerText = filtered.length;
        document.getElementById('vlrEstimado').innerText = totalVlr.toLocaleString('pt-BR', {style:'currency', currency:'BRL'});
    }
}

document.addEventListener('DOMContentLoaded', () => new AgSUSApp());
