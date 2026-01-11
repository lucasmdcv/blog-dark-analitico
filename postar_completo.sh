#!/bin/bash
# SYSTEM_ROOT - Deploy Engine v10.6 (Netlify Edition)
# Estetica: Dark/Analitica | Lucas Mendes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SYSTEM_ROOT // AI DEPLOY ENGINE     ${NC}"
echo -e "${CYAN}==========================================${NC}"
if [ -f .env ]; then
HF_TOKEN=$(grep HF_TOKEN .env | cut -d '=' -f2 | sed 's/["'\'']//g' | xargs)
echo -e "${GREEN}[+] Token sanitizado.${NC}"
else
echo -e "${RED}[!] Erro: Arquivo .env ausente.${NC}"
exit 1
fi
TEMA=${1:-"Ciberseguranca Avancada em 2026"}
MODEL="meta-llama/Llama-3.1-8B-Instruct"
echo -e "[*] Alvo: $TEMA"
echo -e "[1/3] Gerando conteudo via Router (Gratuito)..."
RESPONSE=$(curl -s -X POST "https://router.huggingface.co/hf-inference/v1/chat/completions" \
-H "Authorization: Bearer $HF_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Aja como um analista de elite. Escreva um post analitico para um blog dark sobre: $TEMA. Use markdown, inclua hashtags e uma conclusao tecnica.\"}],\"max_tokens\":1200,\"temperature\":0.7}")
RESUMO_IA=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['choices'][0]['message']['content'])" 2>/dev/null)
if [ -z "$RESUMO_IA" ] || [[ "$RESPONSE" == *"error"* ]]; then
echo -e "${RED}[!] Falha na API (Router). Resposta: $RESPONSE${NC}"
exit 1
fi
export RESUMO_IA
export TEMA
python3 - << EOF
import os,json,time,random,sys,requests
from datetime import datetime
resumo_ia=os.getenv("RESUMO_IA")
tema=os.getenv("TEMA")
try:
    if not os.path.exists("images"):os.makedirs("images")
    img_id=random.randint(1,1000)
    img_name=f"img_{int(time.time())}.jpg"
    print("[2/3] Sincronizando assets visuais...")
    res_img=requests.get(f"https://picsum.photos/seed/{img_id}/1600/900",timeout=15)
    with open(f"images/{img_name}","wb") as f:f.write(res_img.content)
    linhas=[l.strip() for l in resumo_ia.split('\n') if l.strip()]
    titulo=linhas[0].replace('#','').replace('*','').strip()
    corpo="\n\n".join(linhas[1:]).replace('*','').strip()
    novo_post={"categoria":"SYSTEM_ROOT","titulo":titulo,"resumo":corpo[:200]+"...","conteudo":corpo,"imagem":f"images/{img_name}","data_hora":datetime.now().strftime("%d/%m/%Y %H:%M"),"autor":"Lucas Mendes","local":"Ceilandia/DF"}
    posts=[]
    if os.path.exists('post.json'):
        with open('post.json','r',encoding='utf-8') as f:
            try:posts=json.load(f)
            except:posts=[]
    posts.insert(0,novo_post)
    with open('post.json','w',encoding='utf-8') as f:json.dump(posts,f,indent=4,ensure_ascii=False)
    print(f"\n[SUCCESS] Deploy Local Concluido: {titulo}")
except Exception as e:print(f"\n[!] Erro no processamento: {e}")
EOF
echo -e "${CYAN}==========================================${NC}"