// Variável de estado global
let lastHash = "";

async function verificarNovidades() {
    // Anti-cache robusto para garantir dados novos do servidor
    const url = `post.json?t=${new Date().getTime()}`;

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error("Database offline");
        
        const posts = await response.json();
        
        // Criamos a digital do estado atual dos posts
        const currentHash = JSON.stringify(posts);

        // SÓ RE-RENDERIZA SE O CONTEÚDO MUDOU
        if (currentHash !== lastHash) {
            console.log("[SYSTEM_ROOT] Mudança detectada no banco. Atualizando interface...");
            lastHash = currentHash;
            renderizarPosts(posts);
        }
    } catch (e) {
        const feed = document.getElementById('news-feed');
        if (!lastHash) { // Se falhar logo na primeira carga
            feed.innerHTML = `<div class="alert alert-danger bg-black border-danger text-danger font-monospace">
                [!] ERRO CRÍTICO: FALHA NA CONEXÃO COM O DATABASE.
            </div>`;
        }
        console.error("Erro na sonda:", e);
    }
}

function renderizarPosts(posts) {
    const feed = document.getElementById('news-feed');
    feed.innerHTML = ''; // Limpa o feed para reconstruir

    posts.forEach(post => {
        const card = `
            <div class="card bg-black border-secondary mb-4 overflow-hidden animate-in">
                <img src="${post.imagem}" class="card-img-top grayscale" alt="Análise Visual" 
                     onerror="this.src='https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80'">
                <div class="card-body border-top border-secondary">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="badge border border-danger text-danger">${post.categoria}</span>
                        <small class="text-secondary font-monospace">${post.data_hora}</small>
                    </div>
                    <h2 class="h4 fw-black text-light">${post.titulo}</h2>
                    <p class="text-light-50 small">${post.resumo}</p>
                    <hr class="border-secondary">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="small text-danger font-monospace">OP: ${post.autor}</span>
                        <span class="small text-secondary font-monospace">${post.local}</span>
                    </div>
                </div>
            </div>
        `;
        feed.innerHTML += card;
    });
}

// --- ORQUESTRAÇÃO DE SISTEMA ---

// Relógio em tempo real (Estética Finch/PoI)
setInterval(() => {
    const relogio = document.getElementById('relogio');
    if (relogio) relogio.innerText = new Date().toLocaleTimeString('pt-BR');
}, 1000);

// Sonda de verificação (Verifica a cada 10 segundos)
setInterval(verificarNovidades, 10000);

// Disparo inicial imediato
verificarNovidades();