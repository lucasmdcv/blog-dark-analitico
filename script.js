async function carregarPosts() {
    const feed = document.getElementById('news-feed');
    // Adicionamos um timestamp para evitar que o navegador mostre posts antigos (Anti-Cache)
    const url = `post.json?t=${new Date().getTime()}`;

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error("Database não encontrada");
        
        const posts = await response.json();
        feed.innerHTML = ''; // Limpa o "Scanning..."

        posts.forEach(post => {
            const card = `
                <div class="card bg-black border-secondary mb-4 overflow-hidden animate-in">
                    <img src="${post.imagem}" class="card-img-top grayscale" alt="Análise Visual" onerror="this.src='https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80'">
                    <div class="card-body border-top border-secondary">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="badge border border-danger text-danger">${post.categoria}</span>
                            <small class="text-secondary font-monospace">${post.data_hora}</small>
                        </div>
                        <h2 class="h4 fw-black text-light">${post.titulo}</h2>
                        <p class="text-muted small">${post.resumo}</p>
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
    } catch (error) {
        feed.innerHTML = `
            <div class="alert alert-danger bg-black border-danger text-danger font-monospace">
                [!] ERRO DE SINCRONIA: DATABASE OFFLINE OU EM MANUTENÇÃO.
            </div>`;
    }
}

// Inicializa a varredura
carregarPosts();

// Relógio em tempo real (Estética Finch/PoI)
setInterval(() => {
    const relogio = document.getElementById('relogio');
    relogio.innerText = new Date().toLocaleTimeString('pt-BR');
}, 1000);