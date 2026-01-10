#!/data/data/com.termux/files/usr/bin/bash

# Estética Dark/Analítica
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}      SISTEMA SYSTEM_ROOT - TERMUX        ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. Executa o Script Python (A IA gerando o post)
echo -e "\n${YELLOW}[1/3] GERANDO CONTEÚDO COM IA...${NC}"
python postar_completo.py

# 2. Sincronização com GitHub
echo -e "\n${YELLOW}[2/3] SINCRONIZANDO COM GITHUB...${NC}"
git add .
git commit -m "SYSTEM_ROOT: Novo post via script automatizado"
git push origin main

# 3. Finalização e Link
echo -e "\n${YELLOW}[3/3] FINALIZANDO DEPLOY NO NETLIFY...${NC}"
echo "Aguardando 5 segundos para o build..."
sleep 5

echo -e "\n${CYAN}==========================================${NC}"
echo -e "${CYAN}    PROCESSO CONCLUÍDO! SITE ATUALIZADO.  ${NC}"
echo -e "${CYAN}==========================================${NC}"
echo -e "Acesse: https://blog-dark-analitico.netlify.app/"
