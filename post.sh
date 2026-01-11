#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v3.0 (Termux Optimized)
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Carregamento Manual do .env (Evita AssertionError do Python)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo -e "${GREEN}[+] Variáveis de ambiente carregadas.${NC}"
else
    echo -e "${RED}[!] Erro: Arquivo .env não encontrado.${NC}"
    exit 1
fi

# 2. Execução do Core Python
# Passamos o tema como argumento $1 para o Bash, que repassa para o Python
TEMA=${1:-"Cibersegurança Avançada em 2026"}

python3 - << EOF
import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient

def executar():
    # Pega as variáveis exportadas pelo Bash
    token_hf = os.getenv("HF_TOKEN")
    tema = "$TEMA"
    
    if not token_hf:
        print("${RED}[!] Erro: HF_TOKEN não detectado.${NC}")
        return

    client = InferenceClient(token=token_hf)
    
    prompt = (
        f"Aja como um Editor-Chefe de Tecnologia. Escreva uma reportagem de impacto sobre {tema}. "
        f"ESTRUTURA OBRIGATÓRIA: 1. TÍTULO urgente (G1), 2. LEAD direto, 3. ANÁLISE TÉCNICA densa, 4. CONCLUSÃO 2026."
    )

    try:
        print(f"[*] Alvo: {tema}")
        print("[1/3] Consultando Llama-3 via HuggingFace...")
        
        response = client.chat_completion(
            model="meta-llama/Meta-Llama-3-8B-Instruct",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=1500,
            temperature=0.7
        )
        resumo_ia = response.choices[0].message.content
        
        # Tratamento de Imagem
        img_id = random.randint(1, 1000)
        img_name = f"img_{int(time.time())}.jpg"
        if not os.path.exists("images"): os.makedirs("images")
        
        print("[2/3] Sincronizando assets visuais...")
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=10)
        with open(f"images/{img_name}", "wb") as f:
            f.write(res_img.content)

        # Parsing do JSON
        linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
        titulo = linhas[0].replace('#', '').replace('**', '').strip()
        corpo = "\n\n".join(linhas[1:]).replace('**', '').strip()

        novo_post = {
            "categoria": "SYSTEM_ROOT",
            "titulo": titulo,
            "resumo": corpo,
            "imagem": f"images/{img_name}",
            "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "autor": "Lucas Mendes",
            "local": "Ceilândia/DF"
        }

        # Persistência
        posts = []
        if os.path.exists('post.json'):
            with open('post.json', 'r', encoding='utf-8') as f:
                try: posts = json.load(f)
                except: posts = []
        
        posts.insert(0, novo_post)
        with open('post.json', 'w', encoding='utf-8') as f:
            json.dump(posts, f, indent=4, ensure_ascii=False)

        print(f"\n${GREEN}[SUCCESS] Deploy concluído: {titulo}${NC}")

    except Exception as e:
        print(f"${RED}[!] Falha no Pipeline: {e}${NC}")

executar()
EOF

echo -e "${CYAN}==========================================${NC}"
echo -e "Status: https://blog-dark-analitico.netlify.app/"

