import os
from dotenv import load_dotenv
load_dotenv()

# Agora a chave não fica mais "visível" no código
TOKEN_HF = os.getenv("HF_TOKEN")

import requests
import json
import os
from huggingface_hub import InferenceClient

# --- CONFIGURAÇÃO ---
TOKEN_HF = "" # Pegue em huggingface.co/settings/tokens
client = InferenceClient(token=TOKEN_HF)

def gerar_blog_ia(tema):
    print(f"\n[>] Analisando tema: {tema}")
    
    # 1. GERAR TEXTO
    prompt_texto = f"<s>[INST] Escreva um título curto e um resumo nerd impactante sobre {tema} em Português. [/INST]"
    texto_raw = client.text_generation(prompt_texto, model="mistralai/Mistral-7B-Instruct-v0.2", max_new_tokens=150)
    
    # 2. GERAR IMAGEM (O Diferencial)
    print("[>] Criando arte visual via Stable Diffusion...")
    prompt_imagem = f"High quality geek digital art of {tema}, cinematic lighting, 4k, trending on artstation"
    imagem = client.text_to_image(prompt_imagem, model="stabilityai/stable-diffusion-2-1")
    
    # Salva a imagem localmente
    nome_arquivo_img = f"img_{int(os.path.getmtime('.'))}.jpg"
    imagem.save(nome_arquivo_img)
    print(f"[OK] Imagem salva como: {nome_arquivo_img}")

    # 3. ATUALIZAR JSON
    novo_post = {
        "categoria": "IA_NERD",
        "titulo": f"IA Report: {tema}",
        "resumo": texto_raw.strip(),
        "imagem": nome_arquivo_img, # Campo novo para o HTML ler
        "tempo": "Agora",
        "local": "AI Lab"
    }

    with open('posts.json', 'r+', encoding='utf-8') as f:
        posts = json.load(f)
        posts.insert(0, novo_post)
        f.seek(0)
        json.dump(posts, f, indent=4, ensure_ascii=False)

if __name__ == "__main__":
    tema_input = input("Sobre o que a IA deve criar hoje? ")
    gerar_blog_ia(tema_input)