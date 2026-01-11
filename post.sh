#!/bin/bash
# SYSTEM_ROOT - Deploy Automático v2.0
# Estética: Dark/Analítica | Owner: Lucas Mendes

CYAN='\033[0;36m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

clear
echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│      SYSTEM_ROOT // DEPLOY ENGINE      │${NC}"
echo -e "${CYAN}└────────────────────────────────────────┘${NC}"

# Input do Tema
TEMA_INPUT=${1:-"Vulnerabilidades em Sistemas Críticos 2026"}

# Execução do Core
python3 - << EOF
import os, json, sys
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

load_dotenv()
HF_TOKEN = os.getenv("HF_TOKEN")

if not HF_TOKEN:
    print("${RED}[!] Erro: HF_TOKEN não encontrado no .env${NC}")
    sys.exit(1)

client = InferenceClient(token=HF_TOKEN)

def deploy():
    tema = "$TEMA_INPUT"
    print(f"${GRAY}[*] Alvo de análise:${NC} {tema}")
    
    # Prompt de Engenharia Analítica
    prompt = (f"Contexto: Janeiro de 2026. Estética Cyberpunk/Analítica. "
              f"Aja como um analista de inteligência. Escreva um report urgente sobre: {tema}. "
              f"Estrutura: Título (uppercase), Lead Técnico, Impacto em Ceilândia/DF e Projeção.")

    try:
        print("${GRAY}[1/3] Handshake com HuggingFace...${NC}")
        res = client.chat_completion(
            model="meta-llama/Meta-Llama-3-8B-Instruct",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=1000
        ).choices[0].message.content
        
        # Processamento de Dados
        partes = res.split('\n')
        titulo = partes[0].replace('#', '').strip()
        corpo = "\n".join(partes[1:]).strip()

        post = {
            "id": datetime.now().strftime("%Y%m%d%H%M%S"),
            "categoria": "CYBER_INTEL",
            "titulo": titulo,
            "resumo": corpo,
            "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "autor": "Lucas Mendes",
            "tags": ["Kali", "Cybersecurity", "DF_Ceilandia"]
        }

        # Persistência Segura
        file_path = 'post.json'
        if not os.path.exists(file_path):
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump([], f)

        with open(file_path, 'r+', encoding='utf-8') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                data = []
            
            data.insert(0, post)
            f.seek(0)
            json.dump(data, f, indent=4, ensure_ascii=False)
            f.truncate()
        
        print(f"${CYAN}[+] Sucesso: {titulo}${NC}")
        
    except Exception as e:
        print(f"${RED}[!] Falha Crítica no Pipeline: {e}${NC}")

deploy()
EOF

echo -e "${GRAY}------------------------------------------${NC}"
echo -e "LOG: Status atualizado em https://blog-dark-analitico.netlify.app/"
