#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v5.0 (Direct API Mode)
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Carregamento e Limpeza de Variáveis
if [ -f .env ]; then
    # O sed remove aspas e espaços extras que podem corromper o Token
    export HF_TOKEN=$(grep HF_TOKEN .env | cut -d '=' -f2 | sed 's/["'\'']//g' | xargs)
    echo -e "${GREEN}[+] Token extraído e sanitizado.${NC}"
else
    echo -e "${RED}[!] Erro: Arquivo .env ausente.${NC}"
    exit 1
fi

TEMA=${1:-"Cibersegurança Avançada em 2026"}

# 2. Execução via Python (Método Direct Generation)
python3 - << EOF
import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient

def executar():
    token = os.getenv("HF_TOKEN")
    tema = "$TEMA"
    
    # Endpoint direto para evitar o Auto-Router
    model_id = "meta-llama/Meta-Llama-3-8B-Instruct"
    client = InferenceClient(model=model_id, token=token)

    prompt = (
        f"<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n"
        f"Aja como um Editor-Chefe de Tecnologia. Escreva uma reportagem urgente sobre {tema}. "
        f"ESTRUTURA: 1. TÍTULO estilo G1, 2. LEAD direto, 3. ANÁLISE TÉCNICA densa, 4. CONCLUSÃO 2026. "
        f"Responda apenas com o texto da reportagem.<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n"
    )

    try:
        print(f"[*] Alvo: {tema}")
        print("[1/3] Gerando reportagem (Direct API)...")
        
        # Uso do text_generation para bypassar o erro de roteamento
        resumo_ia = client.text_generation(
            prompt,
            max_new_tokens=1500,
            temperature=0.7,
            stop_sequences=["<|eot_id|>"]
        )

        # Captura de Imagem
        img_id = random.randint(1, 1000)
        img_name = f"img_{int(time.time())}.jpg"
        if not os.path.exists("images"): os.makedirs("images")
        
        print("[2/3] Sincronizando assets visuais...")
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=10)
        with open(f"images/{img_name}", "wb") as f:
            f.write(res_img.content)

        # Parsing JSON
        linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
        titulo = linhas[0].replace('#', '').replace('*', '').strip()
        corpo = "\n\n".join(linhas[1:]).replace('*', '').strip()

        novo_post = {
            "categoria": "SYSTEM_ROOT",
            "titulo": titulo,
            "resumo": corpo,
            "imagem": f"images/{img_name}",
            "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "autor": "Lucas Mendes",
            "local": "Ceilândia/DF"
        }

        posts = []
        if os.path.exists('post.json'):
            with open('post.json', 'r', encoding='utf-8') as f:
                try: posts = json.load(f)
                except: posts = []
        
        posts.insert(0, novo_post)
        with open('post.json', 'w', encoding='utf-8') as f:
            json.dump(posts, f, indent=4, ensure_ascii=False)

        print(f"\n${GREEN}[SUCCESS] Deploy: {titulo}${NC}")

    except Exception as e:
        print(f"${RED}[!] Erro Crítico: {e}${NC}")

executar()
EOF

echo -e "${CYAN}==========================================${NC}"

