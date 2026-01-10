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
    
    # 1. GERAÇÃO DE TEXTO
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

    # 2. GERAÇÃO DE IMAGEM E PASTA
    print("[2/3] Gerando imagem com Stable Diffusion XL...")
    folder = 'images'
    if not os.path.exists(folder):
        os.makedirs(folder)

    prompt_img = f"Digital art of {tema}, cinematic lighting, 4k, dark aesthetic, high quality"
    imagem = client.text_to_image(prompt_img, model="stabilityai/stable-diffusion-xl-base-1.0")
    
    nome_arquivo = f"img_{int(time.time())}.jpg"
    caminho_completo = os.path.join(folder, nome_arquivo)
    imagem.save(caminho_completo)

    # 3. TRATAMENTO DE DADOS
    agora = datetime.now()
    data_formatada = agora.strftime("%d/%m/%Y às %H:%M")

    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
    primeira_linha = linhas[0].replace('**', '').replace('#', '').strip()
    
    if ":" in primeira_linha:
        titulo_final = primeira_linha.split(':', 1)[1].strip()
    else:
        titulo_final = primeira_linha

    if len(titulo_final) < 5:
        titulo_final = tema.capitalize()

    resumo_final = "\n".join(linhas[1:]).replace('**', '').strip()
    if not resumo_final:
        resumo_final = resumo_ia.replace('**', '').strip()

    # 4. ESTRUTURA DO JSON
    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_final, 
        "resumo": resumo_final,
        "imagem": f"images/{nome_arquivo}", # Caminho relativo para o site
        "data_hora": data_formatada,
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

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

    # 5. SINCRONIZAÇÃO COM GITHUB (O "ARROCHE" FINAL)
    print(f"[3/3] Sincronizando com GitHub...")
    os.system("git add .") # Pega a nova pasta images e o posts.json de uma vez
    os.system(f'git commit -m "SYSTEM_ROOT: Novo post - {tema}"')
    os.system("git push origin main")
    
    print(f"\n[SUCESSO] Post '{titulo_final}' enviado por Lucas Mendes!")

if __name__ == "__main__":
    gerar_e_subir()
    
    
# ... (final do salvamento do JSON)
    with open('posts.json', 'w', encoding='utf-8') as f:
        json.dump(posts, f, indent=4, ensure_ascii=False)
    
    print(f"\n[OK] JSON e Imagem salvos localmente.")    