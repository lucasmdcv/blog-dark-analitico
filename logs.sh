#!/data/data/com.termux/files/usr/bin/bash

# Cores Analíticas
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}[!] ACESSANDO HISTÓRICO DE TRANSMISSÕES...${NC}"
echo -e "${CYAN}------------------------------------------${NC}"

# Mostra os últimos 10 commits formatados
git log -n 10 --pretty=format:"%C(yellow)%h%Creset %C(cyan)%ad%Creset | %s" --date=format:"%d/%m/%Y %H:%M"

echo -e "\n${CYAN}------------------------------------------${NC}"
echo -e "${YELLOW}[*] FIM DO RELATÓRIO.${NC}"
