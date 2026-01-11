#!/bin/bash
# Estética Dark/Analítica - Lucas Mendes
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SISTEMA SYSTEM_ROOT - DEPLOY        ${NC}"
echo -e "${CYAN}==========================================${NC}"

# Chama o Python passando o tema (argumento $1)
python3 << EOF
import os, json, time, random, sys, requests
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

load_dotenv()
client = InferenceClient(token=os.getenv("HF_TOKEN"))

def executar():
    tema = "$1" if "$1" != "" else "Cibersegurança Avançada"
    print(f"[*] Alvo: {tema}")

    prompt = (f"Aja como Editor-Chefe de Tech. Reportagem urgente estilo G1 sobre {tema}. "
              f"Título impactante, Lead direto, análise densa e conclusão 2026.")

    try:
        print("[1/3] Consultando Llama-3 via HuggingFace...")
        res = client.chat_completion(
            model="meta-llama/Meta-Llama-3-8B-Instruct",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=1500
        ).choices[0].message.content
        
        # Parse básico
        linhas = [l.strip() for l in res.split('\n') if l.strip()]
        titulo = linhas[0].replace('#', '').strip()
        corpo = "\n\n".join(linhas[1:])

        novo_post = {
            "categoria": "SYSTEM_ROOT",
            "titulo": titulo,
            "resumo": corpo,
            "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "autor": "Lucas Mendes",
            "local": "Ceilândia/DF"
        }

        with open('post.json', 'r+', encoding='utf-8') as f:
            data = json.load(f)
            data.insert(0, novo_post)
            f.seek(0)
            json.dump(data, f, indent=4, ensure_ascii=False)
        
        print(f"[+] Deploy concluído: {titulo}")
    except Exception as e:
        print(f"[!] Falha no pipeline: {e}")

executar()
EOF

echo -e "${CYAN}==========================================${NC}"
echo -e "Status: https://blog-dark-analitico.netlify.app/"
