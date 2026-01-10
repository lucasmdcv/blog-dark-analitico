import os
import json
import time
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

# Configurações Iniciais
load_dotenv()
TOKEN_HF = os.getenv("HF_TOKEN")
client = InferenceClient(token=TOKEN_HF)

def gerar_e_subir():
    tema = input("Qual o tema do post? ")
    
    print("[1/3] Gerando texto com Llama-3 (IA)...")
    messages = [
        {"role": "user", "content": f"Escreva um título e um resumo nerd impactante sobre {tema} em Português do Brasil. Seja direto e analítico."}
    ]
    
    response = client.chat_completion(
        model="meta-llama/Meta-Llama-3-8B-Instruct", 
        messages=messages,
        max_tokens=150
    )
    resumo_ia = response.choices[0].message.content

    print("[2/3] Gerando imagem com Stable Diffusion XL...")
    prompt_img = f"Digital art of {tema}, cinematic lighting, 4k, dark aesthetic, high quality"
    imagem = client.text_to_image(prompt_img, model="stabilityai/stable-diffusion-xl-base-1.0")
    
    nome_img = f"img_{int(time.time())}.jpg"
    imagem.save(nome_img)

    # --- TRATAMENTO DE DADOS (ADS STYLE) ---
    agora = datetime.now()
    data_formatada = agora.strftime("%d/%m/%Y às %H:%M")

    # Lógica para limpar o título e o resumo (evita o corte de apenas uma letra)
    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
    
    # Limpa asteriscos e tags de Markdown da primeira linha
    primeira_linha = linhas[0].replace('**', '').replace('#', '').strip()
    
    if ":" in primeira_linha:
        # Pega tudo DEPOIS do primeiro ":" (resolve o problema do "Radar: o")
        titulo_final = primeira_linha.split(':', 1)[1].strip()
    else:
        titulo_final = primeira_linha

    # Fallback caso a IA falhe na formatação
    if len(titulo_final) < 5:
        titulo_final = tema.capitalize()

    # Limpa o corpo do texto de marcações indesejadas
    resumo_final = "\n".join(linhas[1:]).replace('**', '').strip()
    if not resumo_final:
        resumo_final = resumo_ia.replace('**', '').strip()

    # --- ESTRUTURA FINAL DO JSON ---
    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_final, 
        "resumo": resumo_final,
        "imagem": nome_img,
        "data_hora": data_formatada,
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

    # Persistência no JSON
    try:
        if os.path.exists('posts.json'):
            with open('posts.json', 'r', encoding='utf-8') as f:
                posts = json.load(f)
        else:
            posts = []
    except (json.JSONDecodeError, FileNotFoundError):
        posts = []

    posts.insert(0, novo_post)

    with open('posts.json', 'w', encoding='utf-8') as f:
        json.dump(posts, f, indent=4, ensure_ascii=False)

    print(f"[3/3] Sincronizando com GitHub...")
    os.system("git add .")
    os.system(f'git commit -m "Auto-post IA: {tema}"')
    os.system("git push origin main")
    
    print(f"\n[SUCESSO] Post '{titulo_final}' enviado por Lucas Mendes!")

if __name__ == "__main__":
    gerar_e_subir()
    
    # Criar a pasta images se não existir
    if not os.path.exists('images'):
        os.makedirs('images')

    print("[2/3] Gerando imagem com Stable Diffusion XL...")
    # ... código de geração ...
    
    nome_img = f"img_{int(time.time())}.jpg"
    caminho_imagem = os.path.join('images', nome_img) # Define o caminho: images/img_xxx.jpg
    imagem.save(caminho_imagem)

    # No JSON, salvamos apenas o nome ou o caminho relativo
    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_final, 
        "resumo": resumo_final,
        "imagem": f"images/{nome_img}", # IMPORTANTE: Incluir o prefixo da pasta aqui
        "data_hora": data_formatada,
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

    # ... parte do Git ...
    os.system("git add posts.json")
    os.system("git add images/*.jpg") # Adiciona todas as fotos da nova pasta
    os.system(f'git commit -m "Post organizado: {tema}"')
    os.system("git push origin main")
    
    
    # --- NOVA LÓGICA DE DIRETÓRIO DE IMAGENS ---
    folder = 'images'
    if not os.path.exists(folder):
        os.makedirs(folder)
        print(f"[*] Pasta '{folder}' criada com sucesso.")

    print("[2/3] Gerando imagem com Stable Diffusion XL...")
    prompt_img = f"Digital art of {tema}, cinematic lighting, 4k, dark aesthetic"
    imagem = client.text_to_image(prompt_img, model="stabilityai/stable-diffusion-xl-base-1.0")
    
    # Nome do arquivo e caminho completo
    nome_arquivo = f"img_{int(time.time())}.jpg"
    caminho_completo = os.path.join(folder, nome_arquivo)
    
    imagem.save(caminho_completo)
    print(f"[*] Imagem salva em: {caminho_completo}")

    # --- ESTRUTURA DO JSON COM CAMINHO DA PASTA ---
    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_final, 
        "resumo": resumo_final,
        "imagem": f"images/{nome_arquivo}", # O site vai ler a partir da pasta images/
        "data_hora": data_formatada,
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

    # ... (lógica de inserção no posts.json continua igual) ...

    # --- GIT PUSH ATUALIZADO PARA A PASTA IMAGES ---
    print(f"[3/3] Sincronizando com GitHub...")
    os.system("git add posts.json")
    os.system("git add images/*.jpg") # Adiciona especificamente as fotos da pasta
    os.system(f'git commit -m "Organização: Imagem movida para /images - {tema}"')
    os.system("git push origin main")