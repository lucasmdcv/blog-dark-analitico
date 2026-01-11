// Variável de estado global (Digital do Banco de Dados)
let lastHash = "";

async function verificarNovidades() {
    // Anti-cache com timestamp para garantir que a Netlify entregue o arquivo novo
    const url = `post.json?t=${new Date().getTime()}`;

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error("Database offline");
        
        const posts = await response.json();
        
        // Criamos o hash do estado atual (se mudar um vírgula, o site percebe)
        const currentHash = JSON.stringify(posts);

        if (currentHash !== lastHash) {
            console.log("[SYSTEM_ROOT] Novo pacote de dados detectado. Sincronizando...");
            lastHash = currentHash;
            renderizarPosts(posts);
        }
    } catch (e) {
        console.error("Erro na sonda de monitoramento:", e);
        // Se falhar e não houver posts na tela, avisa o operador
        if (!lastHash) {
            document.getElementById('news-feed').innerHTML = `
                <div class="alert alert-danger bg-black border-danger text-danger font-monospace">
                    [!] ERRO CRÍTICO: FALHA NA COMUNICAÇÃO COM O NÚCLEO.
                </div>`;
        }
    }
}

function renderizarPosts(posts) {
    const feed = document.getElementById('news-feed');
    feed.innerHTML = ''; 

    posts.forEach(post => {
        // Fallback de imagem: Se o caminho no JSON falhar, chama o Picsum Aleatório
        const fallbackImg = `https://picsum.photos/seed/${Math.random()}/1600/900?grayscale`;
        
        const card = `
            <div class="card bg-black border-secondary mb-4 overflow-hidden animate-in shadow-lg">
                <img src="${post.imagem}" 
                     class="card-img-top img-analitica" 
                     alt="Visual Analysis" 
                     onerror="this.src='${fallbackImg}'">
                
                <div class="card-body border-top border-secondary">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="badge border border-danger text-danger font-monospace">${post.categoria}</span>
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

// --- ORQUESTRAÇÃO ---

// Relógio Estilo Finch
setInterval(() => {
    const relogio = document.getElementById('relogio');
    if (relogio) relogio.innerText = new Date().toLocaleTimeString('pt-BR');
}, 1000);

// Sonda de Varredura (10 segundos)
setInterval(verificarNovidades, 10000);

// Primeira Varredura
verificarNovidades();