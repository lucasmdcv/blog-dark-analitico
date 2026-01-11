#!/bin/bash
# SYSTEM_ROOT - GitHub Sync Engine
# Estética: Dark/Analítica | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Iniciando sincronização com o repositório...${NC}"

# 1. Adicionar arquivos
git add .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Arquivos indexados.${NC}"
else
    echo -e "${RED}[!] Erro ao indexar arquivos.${NC}"
    exit 1
fi

# 2. Commit (Mensagem dinâmica com data/hora)
DATA_HORA=$(date '+%d/%m/%Y %H:%M:%S')
MENSAGEM="update: system_root deployment - $DATA_HORA"

git commit -m "$MENSAGEM"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Commit realizado: $MENSAGEM${NC}"
else
    echo -e "${RED}[!] Nada para commitar ou erro no processo.${NC}"
    # Não saímos aqui porque o Push ainda pode ser necessário
fi

# 3. Push para o Main
echo -e "${CYAN}[*] Realizando Push para o GitHub...${NC}"
git push origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[DONE] Sincronização completa. Terminal seguro.${NC}"
else
    echo -e "${RED}[!] Erro no Push. Verifique sua conexão ou GITHUB_TOKEN.${NC}"
    exit 1
fi
# ... (parte inicial do script igual)

git commit -m "$MENSAGEM"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Commit realizado.${NC}"
else
    echo -e "${RED}[!] Nada para commitar.${NC}"
fi

# NOVIDADE: Sincroniza antes de subir
echo -e "${CYAN}[*] Puxando atualizações remotas (Pull)...${NC}"
git pull origin main --rebase

# 3. Push para o Main
echo -e "${CYAN}[*] Realizando Push para o GitHub...${NC}"
git push origin main
# ... (resto do script)

