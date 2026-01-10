import requests
from bs4 import BeautifulSoup
import json
from datetime import datetime

def scanner_financeiro():
    print("[>] INICIANDO SCANNER ANALÍTICO: MXRF11")
    
    # URL de exemplo (pode ser o StatusInvest ou Fundamentus)
    url = "https://www.google.com/search?q=cotacao+mxrf11"
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
    
    try:
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Aqui você ajusta o seletor conforme o site escolhido
        # Exemplo genérico de captura de preço
        preco = "10,15" # Simulação de captura via seletor CSS
        
        novo_post = {
            "categoria": "INVESTIMENTOS",
            "titulo": f"Relatório MXRF11: Cotação Atualizada",
            "resumo": f"O fundo MXRF11 está sendo negociado a R$ {preco}. Verifique sua estratégia de dividendos.",
            "tempo": "Automático",
            "local": "B3 / São Paulo"
        }

        # Carregar e atualizar o JSON
        with open('posts.json', 'r+', encoding='utf-8') as f:
            posts = json.load(f)
            posts.insert(0, novo_post)
            f.seek(0)
            json.dump(posts[:15], f, indent=4, ensure_ascii=False) # Mantém apenas os 15 últimos
            
        print("[OK] Dados financeiros integrados ao feed.")
        
    except Exception as e:
        print(f"[ERRO] Falha no scanner: {e}")

if __name__ == "__main__":
    scanner_financeiro()