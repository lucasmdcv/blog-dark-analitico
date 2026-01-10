function startClock() {
    setInterval(() => {
        const now = new Date();
        const clockEl = document.getElementById('relogio');
        if(clockEl) clockEl.innerText = now.toLocaleTimeString();
    }, 1000);
}

async function fetchNews() {
    const feed = document.getElementById('news-feed');
    try {
        const response = await fetch('posts.json?v=' + Date.now());
        if (!response.ok) throw new Error('Falha no JSON');
        const posts = await response.json();
        
        feed.innerHTML = posts.map(post => `
            <article class="news-card">
                <span class="cat-tag">${post.categoria}</span>
                <a href="#" class="news-title">${post.titulo}</a>
                <p class="news-excerpt">${post.resumo}</p>
                <div class="news-meta">
                    ${post.tempo.toUpperCase()} • EM ${post.local.toUpperCase()}
                </div>
            </article>
        `).join('');
    } catch (error) {
        feed.innerHTML = `<div class="alert alert-light text-center border">Verifique o seu posts.json...</div>`;
    }
}

// Inicialização
startClock();
fetchNews();
setInterval(fetchNews, 30000); // Atualiza estilo G1