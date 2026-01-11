#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v10.0 (Router Fix & Anti-Billing)
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Extração Limpa do Token
if [ -f .env ]; then
    HF_TOKEN=$(grep HF_TOKEN .env | cut -d '=' -f2 | sed 's/["'\'']//g' | xargs)
    echo -e "${GREEN}[+] Token sanitizado.${NC}"
else
    echo -e "${RED}[!] Erro: Arquivo .env ausente.${NC}"
    exit 1
fi

TEMA=${1:-"Cibersegurança Avançada em 2026"}
MODEL="meta-llama/Meta-Llama-3-8B-Instruct"

echo -e "[*] Alvo: $TEMA"
echo -e "[1/3] Gerando conteúdo via Router (Gratuito)..."

# 2. Requisição via NOVO ROTEADOR (Bypass do Erro 410 e Provedores Pagos)
# Adicionado x-use-cache e bloqueio de provedores externos para evitar cobranças
RESPONSE=$(curl -s -X POST "https://router.huggingface.co/hf-inference/models/$MODEL" \
    -H "Authorization: Bearer $HF_TOKEN" \
    -H "Content-Type: application/json" \
    -H "x-use-cache: true" \
    -d "{
        \"inputs\": \"<|begin_of_text|><|start_header_id|>user<|end_header_id|>Aja como um analista de elite. Escreva um post sobre $TEMA. TÍTULO estilo G1, LEAD direto, ANÁLISE TÉCNICA e CONCLUSÃO 2026. Responda apenas em Português.<|eot_id|><|start_header_id|>assistant<|end_header_id|>\",
        \"parameters\": {\"max_new_tokens\": 1200, \"temperature\": 0.7}
    }")

# Extração segura do JSON
RESUMO_IA=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['generated_text'].split('<|end_header_id|>')[-1].strip() if isinstance(data, list) else data.get('generated_text', ''))" 2>/dev/null)

if [ -z "$RESUMO_IA" ] || [[ "$RESPONSE" == *"error"* ]]; then
    echo -e "${RED}[!] Falha na API (Router). Resposta: $RESPONSE${NC}"
    exit 1
fi

# 3. Processamento de Assets e JSON
export RESUMO_IA
export TEMA

python3 - << EOF
import os, json, time, random, sys, requests
from datetime import datetime

resumo_ia = os.getenv("RESUMO_IA")
tema = os.getenv("TEMA")

try:
    if not os.path.exists("images"): os.makedirs("images")
    img_id = random.randint(1, 1000)
    img_name = f"img_{int(time.time())}.jpg"
    
    print("[2/3] Sincronizando assets visuais...")
    res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=15)
    with open(f"images/{img_name}", "wb") as f:
        f.write(res_img.content)

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
    print(f"${RED}[!] Erro no processamento: {e}${NC}")
EOF

echo -e "${CYAN}==========================================${NC}"
