#!/data/data/com.termux/files/usr/bin/bash

# Cores para o estilo Analítico
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[!] INICIANDO SYNC: blog-dark-analitico${NC}"

# 1. Configurar o diretório (O Termux precisa de permissão de escrita)
REPO_URL="https://github.com/lucasmdcv/blog-dark-analitico"

# 2. Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${RED}[ERROR] Git não instalado. Execute: pkg install git${NC}"
    exit 1
fi

# 3. Procedimento de Sincronização Agressiva (Reset)
echo -e "${GREEN}[*] Buscando dados do GitHub...${NC}"
git fetch --all

echo -e "${GREEN}[*] Forçando atualização (Hard Reset)...${NC}"
git reset --hard origin/main

echo -e "${GREEN}[*] Limpando arquivos residuais...${NC}"
# Protegendo o próprio script de ser apagado se não estiver no git
git clean -fd -e sync.sh

echo -e "${CYAN}======================================"
echo -e "[SUCCESS] Sistema Termux Atualizado."
echo -e "======================================"