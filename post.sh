#!/data/data/com.termux/files/usr/bin/bash

# Cores para estética Dark/Analítica
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[!] INICIANDO TRANSMISSÃO PARA O GITHUB...${NC}"

# 1. Indexar todas as mudanças (incluindo novos arquivos e o próprio post.sh)
git add .

# 2. Criar o ponto na história (Commit) com data e hora
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
git commit -m "Update via Termux: $TIMESTAMP"

# 3. Enviar para a nuvem
echo -e "${GREEN}[*] Enviando para origin main...${NC}"
git push origin main

echo -e "${CYAN}======================================"
echo -e "[SUCCESS] Sistema Termux Sincronizado com Sucesso."
echo -e "======================================"
