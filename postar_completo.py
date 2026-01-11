#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

# 1. SETUP DE AMBIENTE
load_dotenv()
TOKEN_HF = os.getenv("HF_TOKEN")
client = InferenceClient(token=TOKEN_HF)

def executar_pipeline():
    # Captura o tema via argumento do sistema
    tema = sys.argv[1] if len(sys.argv) > 1 else "Cibersegurança Avançada"
    print(f"[*] Operando em: {tema}")

    # 2. GERAÇÃO DE CONTEÚDO (PROMPT PERSUASIVO ESTILO G1)
    prompt_profundo = (
        f"Aja como um Editor-Chefe de Tecnologia. Escreva uma reportagem de impacto sobre {tema}. "
        f"ESTRUTURA OBRIGATÓRIA:\n"
        f"1. TÍTULO: Um título curto, urgente e persuasivo (estilo G1), usando termos como 'Alerta', 'Impacto' ou 'Revelado'.\n"
        f"2. LEAD: Um primeiro parágrafo direto que explica o fato principal de forma impactante.\n"
        f"3. ANÁLISE TÉCNICA: Três ou mais parágrafos densos e prolixos explorando a arquitetura, vetores de ataque e vulnerabilidades.\n"
        f"4. CONCLUSÃO: O impacto futuro e o que esperar em 2026.\n"
        f"Use Português do Brasil, seja analítico, mas mantenha o tom de notícia urgente."
    )

    try:
        print("[1/3] Gerando reportagem profunda com Llama-3...")
        response = client.chat_completion(
            model="meta-llama/Meta-Llama-3-8B-Instruct", 
            messages=[{"role": "user", "content": prompt_profundo}],
            max_tokens=2500, # Capacidade para posts longos
            temperature=0.7  # Criatividade jornalística
        )
        resumo_ia = response.choices[0].message.content
    except Exception as e:
        print(f"Erro IA: {e}"); return

    # 3. IMAGEM ÚNICA (PICSUM)
    img_id = random.randint(1, 1000)
    img_name = f"img_{int(time.time())}.jpg"
    img_path = os.path.join("images", img_name)
    if not os.path.exists("images"): os.makedirs("images")
    
    try:
        print("[2/3] Capturando asset visual...")
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=15)
        with open(img_path, "wb") as f:
            f.write(res_img.content)
    except:
        img_name = "default_tech.jpg"

    # 4. TRATAMENTO E PERSISTÊNCIA (JSON)
    # Separando o título (primeira linha) do resto do corpo
    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
    if not linhas: return

    # O título é a primeira linha, o resumo é todo o resto preservando quebras
    titulo_raw = linhas[0].replace('**', '').replace('#', '').replace('Título:', '').replace('TÍTULO:', '').strip()
    corpo_texto = "\n\n".join(linhas[1:]).replace('**', '').strip()

    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_raw,
        "resumo": corpo_texto,
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

    print(f"\n[SUCESSO] Deploy de '{titulo_raw}' pronto.")

if __name__ == "__main__":
    executar_pipeline()