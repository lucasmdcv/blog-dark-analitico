@echo off
setlocal enabledelayedexpansion

:: Configurações
set REPO_URL=https://github.com/lucasmdcv/blog-dark-analitico
set TARGET_DIR=%cd%

title [SYSTEM MONITOR] - Syncing %REPO_URL%

echo.
echo ==========================================================
echo [!] INICIANDO ATUALIZACAO AGRESSIVA: blog-dark-analitico
echo [!] LOCAL: %TARGET_DIR%
echo ==========================================================
echo.

:: Verifica se o Git está instalado
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git nao encontrado no PATH. Abortando.
    pause
    exit /b
)

:: Verifica se já é um repositório git, se não, inicializa
if not exist ".git" (
    echo [*] Inicializando novo repositorio...
    git init
    git remote add origin %REPO_URL%
)

:: Procedimento de Sincronização
echo [*] Buscando metadados do servidor (fetch)...
git fetch --all

echo [*] Resetando estado local para coincidir com origin/main...
:: O 'reset --hard' descarta qualquer alteração local não commitada.
:: Ajuste 'main' para 'master' se o seu branch principal usar a nomenclatura antiga.
git reset --hard origin/main

echo [*] Limpando arquivos nao rastreados (cleanup)...
git clean -fd

echo.
echo ==========================================================
echo [SUCCESS] Sincronizacao concluida com exito.
echo [STATUS] Sistema atualizado.
echo ==========================================================
echo.

pause