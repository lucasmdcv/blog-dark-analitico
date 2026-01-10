@echo off
title SYSTEM_ROOT > GITHUB_SINC
color 0B
cls

echo ==========================================================
echo           SYSTEM_ROOT: PROTOCOLO DE TRANSMISSAO
echo ==========================================================
echo.

:: 1. Entrar na pasta do projeto
cd /d "C:\site-novo"

:: 2. Verificar status dos arquivos
echo [ANALISE] Verificando alteracoes locais...
git status -s
echo.

:: 3. Adicionar arquivos ao Stage
echo [STAGING] Indexando novos dados (post.json, main.dart)...
git add .

:: 4. Criar o commit com data e hora automática
set data=%date:~-4%-%date:~3,2%-%date:~0,2%
set hora=%time:~0,2%:%time:~3,2%
echo [COMMIT] Gerando hash de seguranca...
git commit -m "Cyber: Sincronia automatica em %data% as %hora%"

:: 5. Empurrar para o GitHub
echo [PUSH] Transmitindo pacotes para o servidor remoto...
git push origin main

echo.
echo ==========================================================
echo           TRANSMISSAO CONCLUIDA COM SUCESSO!
echo ==========================================================
echo.
pause