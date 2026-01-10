@echo off
cd /d "%~dp0"

echo [1] VERIFICANDO AMBIENTE...
if not exist "venv\Scripts\python.exe" (
    echo ERRO: Pasta venv nao encontrada!
    pause
    exit
)

echo [2] INICIANDO POSTAGEM COM IA (LUCAS MENDES)...
.\venv\Scripts\python.exe postar_completo.py

echo.
echo [3] SINCRONIZANDO COM O NETLIFY...
echo O deploy iniciou automaticamente via GitHub.
echo Abrindo seu portal em 5 segundos...
timeout /t 5 >nul

:: Abre o seu domínio do Netlify no navegador padrão
start https://blog-dark-analitico.netlify.app/

echo.
echo ==========================================
echo PROCESSO CONCLUIDO COM SUCESSO!
echo ==========================================
pause