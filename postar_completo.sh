#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v4.0 (Termux Optimized)
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Carregamento Manual do .env (Pula o erro do python-dotenv no Termux)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo -e "${GREEN}[+] Variáveis de ambiente injetadas.${NC}"
else
    echo -e "${RED}[!] Erro: Arquivo .env não encontrado.${NC}"
    exit 1
fi

# 2. Definição do Tema
TEMA=${1:-"Cibersegurança Avançada em 2026"}

# 3. Bloco de Execução Python (Core)
python3 - << EOF
import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient

def executar_pipeline():
    # Injeta variáveis exportadas pelo Bash
    token_hf = os.getenv("HF_TOKEN")
    tema = "$TEMA"
    
    if not token_hf:
        print("${RED}[!] Erro: HF_TOKEN não detectado no ambiente.${NC}")
        return

    # Arrocho Técnico: Configuração explícita para evitar erro de auto-router
    client = InferenceClient(
        model="meta-llama/Meta-Llama-3-8B-Instruct",
        token=token_hf
    )

    prompt_profundo = (
        f"Aja como um Editor-Chefe de Tecnologia. Escreva uma reportagem de impacto sobre {tema}. "
        f"ESTRUTURA OBRIGATÓRIA: 1. TÍTULO urgente (estilo G1), 2. LEAD direto, "
        f"3. ANÁLISE TÉCNICA densa e 4. CONCLUSÃO 2026."
    )

    try:
        print(f"[*] Operando em: {tema}")
        print("[1/3] Gerando reportagem profunda com Llama-3...")
        
        # Uso do chat_completion com parâmetros diretos
        response = client.chat_completion(
            messages=[{"role": "user", "content": prompt_profundo}],
            max_tokens=2000,
            temperature=0.7
        )
        resumo_ia = response.choices[0].message.content

        # Processamento Visual
        img_id = random.randint(1, 1000)
        img_name = f"img_{int(time.time())}.jpg"
        if not os.path.exists("images"): os.makedirs("images")
        
        print("[2/3] Capturando asset visual...")
        res_img = requests.get(f"https://picsum.photos/id/{img_id}/1600/900", timeout=15)
        with open(f"images/{img_name}", "wb") as f:
            f.write(res_img.content)

        # Parsing e Tratamento do Texto
        linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
        if not linhas: return

        titulo = linhas[0].replace('**', '').replace('#', '').strip()
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

        # Sincronia JSON
        posts = []
        if os.path.exists('post.json'):
            with open('post.json', 'r', encoding='utf-8') as f:
                try: posts = json.load(f)
                except: posts = []
        
        posts.insert(0, novo_post)
        with open('post.json', 'w', encoding='utf-8') as f:
            json.dump(posts, f, indent=4, ensure_ascii=False)

        print(f"\n${GREEN}[SUCESSO] Deploy de '{titulo}' concluído.${NC}")

    except Exception as e:
        print(f"${RED}[!] Falha Crítica: {e}${NC}")

executar_pipeline()
EOF

echo -e "${CYAN}==========================================${NC}"
echo -e "Status: https://blog-dark-analitico.netlify.app/"
