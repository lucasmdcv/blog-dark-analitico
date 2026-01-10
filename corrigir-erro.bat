@echo off
cls
echo ==========================================
echo    CORRECAO DE DEPENDENCIAS - SYSTEM_ROOT
echo ==========================================
echo.

echo [1/2] TENTANDO INSTALAR VIA PYTHON MODULE...
python -m pip install --upgrade pip
python -m pip install huggingface-hub python-dotenv

echo.
echo [2/2] VERIFICANDO INSTALACAO...
python -c "import huggingface_hub; import dotenv; print('>>> SUCESSO: Bibliotecas instaladas!')" || echo >>> ERRO: Falha na instalacao.

echo.
echo ==========================================
echo    PROCESSO FINALIZADO. TENTE O POSTAR.BAT
echo ==========================================
pause