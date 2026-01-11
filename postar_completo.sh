
#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v7.0 (Direct API Request)
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Extração limpa do Token
if [ -f .env ]; then
    export HF_TOKEN=$(grep HF_TOKEN .env | cut -d '=' -f2 | sed 's/["'\'']//g' | xargs)
    echo -e "${GREEN}[+] Token sanitizado.${NC}"
else
    echo -e "${RED}[!] Erro: Arquivo .env ausente.${NC}"
    exit 1
fi

TEMA=${1:-"Cibersegurança Avançada em 2026"}

python3 - << EOF
import os, json, time, random, sys, requests
from datetime import datetime

def executar():
    token = os.getenv("HF_TOKEN")
    tema = "$TEMA"
    
    # Endpoint de Inferência Direta
    API_URL = "https://api-inference.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    headers = {"Authorization": f"Bearer {token}"}

    prompt = (
        f"<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n"
        f"Aja como um Editor-Chefe de Tecnologia. Escreva uma reportagem urgente sobre {tema}. "
        f"ESTRUTURA: 1. TÍTULO estilo G1, 2. LEAD direto, 3. ANÁLISE TÉCNICA densa, 4. CONCLUSÃO 2026.\n"
        f"Responda apenas com o texto da reportagem em Português.<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n"
    )

    try:
        print(f"[*] Alvo: {tema}")
        print("[1/3] Solicitando inferência direta à Hugging Face...")
        
        # Requisição HTTP Direta para bypassar o auto-router
        payload = {
            "inputs": prompt,
            "parameters": {"max_new_tokens": 1200, "temperature": 0.7}
        }
        
        response = requests.post(API_URL, headers=headers, json=payload, timeout=60)
        
        if response.status_code != 200:
            print(f"${RED}[!] Erro na API ({response.status_code}): {response.text}${NC}")
            return

        resumo_ia = response.json()[0]['generated_text'].split("<|end_header_id|>")[-1].strip()

        # Assets Visuais
        img_id = random.randint(1, 1000)
        img_name = f"img_{int(time.time())}.jpg"
        if not os.path.exists("images"): os.makedirs("images")
        
        print("[2/3] Sincronizando assets visuais...")
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=15)
        with open(f"images/{img_name}", "wb") as f:
            f.write(res_img.content)

        # Processamento de Texto e JSON
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
