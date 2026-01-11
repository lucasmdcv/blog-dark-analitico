#!/bin/bash
# SYSTEM_ROOT - Command & Control (C2)
# Orquestrador Final | Lucas Mendes

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

# 1. Captura o tema ou define o aleatório
TEMA=${1:-"aleatorio"}

echo -e "${CYAN}[STEP 1/2] Iniciando Motor de IA...${NC}"
./postar_completo.sh "$TEMA"

# Verifica se o post foi gerado com sucesso antes de subir
if [ $? -eq 0 ]; then
    echo -e "${CYAN}[STEP 2/2] Sincronizando com GitHub...${NC}"
    ./passar-github.sh
    echo -e "${GREEN}[DONE] Sistema atualizado e online.${NC}"
else
    echo -e "\033[0;31m[!] Erro na geração. Abortando sincronização.\033[0m"
    exit 1
fi
