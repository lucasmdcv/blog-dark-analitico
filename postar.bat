@echo off
cls
echo ==========================================
echo       SISTEMA SYSTEM_ROOT - LUCAS MENDES
echo ==========================================
echo.

:: 0. Sincroniza antes de começar (Evita o erro de rejected)
echo [0/3] SINCRONIZANDO COM O SERVIDOR...
git pull origin main --quiet

echo.
:: 1. Executa o Script Python para gerar o post e a imagem
echo [1/3] GERANDO CONTEUDO COM IA...
python postar_completo.py

echo.
echo [2/3] SINCRONIZANDO COM GITHUB...
git add .
git commit -m "SYSTEM_ROOT: Novo post via script automatizado"
git push origin main

echo.
echo [3/3] FINALIZANDO DEPLOY NO NETLIFY...
echo Aguardando 5 segundos para o build...
timeout /t 5 >nul

:: Abre o site automaticamente
start https://blog-dark-analitico.netlify.app/

echo.
echo ==========================================
echo    PROCESSO CONCLUIDO! SITE ATUALIZADO.
echo ==========================================
pause