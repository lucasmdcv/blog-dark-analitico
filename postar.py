import json
import os
from datetime import datetime

def postador():
    print("\n--- [LUCAS_NEWS] SISTEMA DE POSTAGEM RÁPIDA ---")
    
    # Inputs
    titulo = input("Título da notícia: ")
    categoria = input("Categoria (GAMES, FILMES, CYBER, F1): ").upper()
    resumo = input("Resumo/Conteúdo: ")
    local = "Brasília/DF" # Padrão para facilitar
    tempo = "Agora"

    novo_post = {
        "categoria": categoria,
        "titulo": titulo,
        "resumo": resumo,
        "tempo": tempo,
        "local": local
    }

    # 1. Tentar carregar posts existentes
    arquivo = 'posts.json'
    if os.path.exists(arquivo):
        with open(arquivo, 'r', encoding='utf-8') as f:
            try:
                posts = json.load(f)
            except:
                posts = []
    else:
        posts = []

    # 2. Inserir no TOPO (Estilo G1)
    posts.insert(0, novo_post)

    # 3. Salvar de volta (com indentação para ficar bonito)
    with open(arquivo, 'w', encoding='utf-8') as f:
        json.dump(posts, f, indent=4, ensure_ascii=False)
    
    print(f"\n[SUCESSO] Notícia '{titulo}' adicionada ao JSON!")

    # 4. Automatizar o Deploy (Opcional - Requer Git instalado)
    deploy = input("\nDeseja subir para o Netlify agora? (s/n): ")
    if deploy.lower() == 's':
        print("[>] Iniciando Deploy...")
        os.system('git add .')
        os.system(f'git commit -m "Post: {titulo}"')
        os.system('git push origin main')
        print("[OK] Site atualizado com sucesso!")

if __name__ == "__main__":
    postador()