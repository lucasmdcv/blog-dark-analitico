#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

# 1. SETUP DE AMBIENTE (LINUX FRIENDLY)
load_dotenv()
TOKEN_HF = os.getenv("HF_TOKEN")
client = InferenceClient(token=TOKEN_HF)

def executar_pipeline():
    # Captura tema do argumento do sistema (GitHub Action)
    tema = sys.argv[1] if len(sys.argv) > 1 else "Tecnologia Analitica"
    
    print(f"[*] Operando em: {tema}")

    # 2. GERAÇÃO DE CONTEÚDO (LLAMA-3)
    try:
        msg = [{"role": "user", "content": f"Título e resumo técnico sobre {tema} em PT-BR. Direto e analítico."}]
        response = client.chat_completion(model="meta-llama/Meta-Llama-3-8B-Instruct", messages=msg, max_tokens=150)
        resumo_ia = response.choices[0].message.content
    except Exception as e:
        print(f"Erro IA: {e}"); return

    # 3. IMAGEM ÚNICA (PICSUM - ACESSO ILIMITADO)
    # Usamos o ID aleatório para garantir que NUNCA repita a imagem
    img_id = random.randint(1, 1000)
    img_name = f"img_{int(time.time())}.jpg"
    img_path = os.path.join("images", img_name)
    
    if not os.path.exists("images"): os.makedirs("images")
    
    try:
        # Picsum é imbatível para evitar o erro 422 de timeout
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=15)
        with open(img_path, "wb") as f:
            f.write(res_img.content)
    except:
        img_name = "default_tech.jpg"

    # 4. TRATAMENTO E PERSISTÊNCIA (JSON)
    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
    titulo = linhas[0].replace('**', '').replace('#', '')
    resumo = " ".join(linhas[1:]).replace('**', '')

    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo,
        "resumo": resumo,
        "imagem": f"images/{img_name}",
        "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M"),
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

    # Sincronia de Banco de Dados
    posts = []
    if os.path.exists('post.json'):
        with open('post.json', 'r', encoding='utf-8') as f:
            try: posts = json.load(f)
            except: posts = []
    
    posts.insert(0, novo_post)
    with open('post.json', 'w', encoding='utf-8') as f:
        json.dump(posts, f, indent=4, ensure_ascii=False)

    print(f"[SUCESSO] Deploy de '{titulo}' pronto.")

if __name__ == "__main__":
    executar_pipeline()