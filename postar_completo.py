import os
import json
import time
import random
import sys # <--- ADICIONADO: Para capturar o tema do Flutter
from datetime import datetime
from huggingface_hub import InferenceClient
import requests
from dotenv import load_dotenv

# Configurações Iniciais
load_dotenv()
TOKEN_HF = os.getenv("HF_TOKEN")
client = InferenceClient(token=TOKEN_HF)

def gerar_e_subir():
    temas_seeds = [
        "O impacto da IA na telemetria da F1 em 2026",
        "Vulnerabilidades de segurança em sistemas de impressão 3D",
        "Engenharia reversa e análise de malwares no Kali Linux",
        "Como a análise de metadados em 2026 prenderia Dexter Morgan",
        "A arquitetura de dados por trás da Máquina de Person of Interest",
        "O futuro do desenvolvimento Mobile com Flutter e integração de IA",
        "Criptografia quântica e o fim da privacidade digital",
        "A evolução do hardware: Da Ender 3 às impressoras de metal",
        "A vulnerabilidade de dia zero", "O impacto da Inteligência Artificial", 
        "A engenharia reversa aplicada", "O vazamento de metadados críticos",
        "A evolução do hardware e firmware", "O protocolo de criptografia quântica",
        "A automação de ataques ofensivos", "A análise forense digital",
        "O monitoramento preditivo de rede", "A exploração de falhas de memória"
    ]

    print("--- SYSTEM_ROOT INTERFACE ---")

    # LÓGICA DE DECISÃO HÍBRIDA (PC vs GITHUB)
    # Se houver argumento do sistema (enviado pelo GitHub), usa ele.
    # Se não houver, e estiver no PC, pede o input.
    tema_input = ""
    
    if len(sys.argv) > 1:
        tema_input = sys.argv[1] # Recebe do GitHub Action
    else:
        # Só pede input se estiver rodando manualmente no PC
        print("Dica: Aperte ENTER para gerar um tema aleatório.")
        tema_input = input("Qual o tema do post? ").strip()
    
    if not tema_input:
        tema = random.choice(temas_seeds)
        print(f"[*] MODO AUTO: Gerando conteúdo sobre: {tema}")
    else:
        tema = tema_input

    # 1. GERAÇÃO DE TEXTO
    print("[1/3] Gerando texto com Llama-3 (IA)...")
    messages = [{"role": "user", "content": f"Escreva um título e um resumo nerd impactante sobre {tema} em Português do Brasil. Seja direto e analítico."}]
    
    try:
        response = client.chat_completion(
            model="meta-llama/Meta-Llama-3-8B-Instruct", 
            messages=messages,
            max_tokens=150
        )
        resumo_ia = response.choices[0].message.content
    except Exception as e:
        print(f"Erro na IA de texto: {e}")
        return

   # 2. BUSCA DE IMAGEM ESTÁVEL (UNSPLASH - SEM COTA IA)
    print("[2/3] Capturando asset visual estável via Unsplash...")
    folder = 'images'
    if not os.path.exists(folder):
        os.makedirs(folder)

    try:
        # Busca imagens baseadas no tema para manter sua estética Dark/Analítica
        query = f"{tema},technology,dark,hacker".replace(" ", ",")
        url_unsplash = f"https://source.unsplash.com/featured/1600x900?{query}"
        
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        response_img = requests.get(url_unsplash, headers=headers, timeout=15)
        
        if response_img.status_code == 200:
            nome_arquivo = f"img_{int(time.time())}.jpg"
            caminho_completo = os.path.join(folder, nome_arquivo)
            with open(caminho_completo, 'wb') as f:
                f.write(response_img.content)
            print(f"[*] Imagem capturada com sucesso: {nome_arquivo}")
        else:
            raise Exception(f"Erro Unsplash: Status {response_img.status_code}")
            
    except Exception as e:
        print(f"Erro no pipeline de imagem (Usando Fallback): {e}")
        # Se tudo falhar, define um nome mas não trava o script
        nome_arquivo = "default_tech.jpg"
        
    # 3. TRATAMENTO DOS DADOS
    agora = datetime.now()
    data_formatada = agora.strftime("%d/%m/%Y às %H:%M")
    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
    
    # Validação para evitar erro de índice se a IA responder vazio
    if not linhas: return

    primeira_linha = linhas[0].replace('**', '').replace('#', '').strip()
    titulo_final = primeira_linha.split(':', 1)[1].strip() if ":" in primeira_linha else primeira_linha
    resumo_final = "\n".join(linhas[1:]).replace('**', '').strip() or resumo_ia.replace('**', '').strip()

    # 4. SALVAMENTO NO JSON
    novo_post = {
        "categoria": "SYSTEM_ROOT",
        "titulo": titulo_final, 
        "resumo": resumo_final,
        "imagem": f"images/{nome_arquivo}",
        "data_hora": data_formatada,
        "autor": "Lucas Mendes",
        "local": "Ceilândia/DF"
    }

    post = []
    if os.path.exists('post.json'):
        try:
            with open('post.json', 'r', encoding='utf-8') as f:
                post = json.load(f)
        except:
            post = []

    post.insert(0, novo_post)

    with open('post.json', 'w', encoding='utf-8') as f:
        json.dump(post, f, indent=4, ensure_ascii=False)

    print(f"\n[SUCESSO] Post '{titulo_final}' processado!")

if __name__ == "__main__":
    gerar_e_subir()