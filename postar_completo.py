import os
import json
import time
import random  # Import necessário para o sorteio
from datetime import datetime
from huggingface_hub import InferenceClient
from dotenv import load_dotenv

# Configurações Iniciais
load_dotenv()
TOKEN_HF = os.getenv("HF_TOKEN")
client = InferenceClient(token=TOKEN_HF)

def gerar_e_subir():
    # LISTA DE TEMAS PARA QUANDO VOCÊ ESTIVER SEM IDEIA (MODO SYSTEM_ROOT)
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
        "O monitoramento preditivo de rede", "A exploração de falhas de memória",
        "na telemetria da F1", "em impressoras 3D industriais", 
        "no ecossistema Kali Linux", "em drones de vigilância urbana", 
        "nos sistemas do Animus (AC)", "no netcode de Street Fighter 6", 
        "em servidores de infraestrutura crítica", "nos códigos de Dexter Morgan", 
        "na Máquina de Person of Interest", "no desenvolvimento com Flutter/Dart",
        "em cenários de guerra cibernética", "para analistas de sistemas sênior", 
        "direto de Ceilândia/DF", "na perspectiva da Deep Web", 
        "em ambientes de produção em 2026", "sob a ótica de segurança ofensiva", 
        "na era do Big Data e IA", "em sistemas legados de alto risco", 
        "para defesa de ativos digitais", "no submundo do hacking ético",
    ]

    print("--- SYSTEM_ROOT INTERFACE ---")
    print("Dica: Aperte ENTER para gerar um tema aleatório.")
    tema_input = input("Qual o tema do post? ").strip()
    
    # LÓGICA DE DECISÃO: TEMA MANUAL OU ALEATÓRIO
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

    # 2. GERAÇÃO DE IMAGEM
    print("[2/3] Gerando imagem com Stable Diffusion XL...")
    folder = 'images'
    if not os.path.exists(folder):
        os.makedirs(folder)

    try:
        prompt_img = f"Digital art of {tema}, cinematic lighting, 4k, dark aesthetic, high quality"
        imagem = client.text_to_image(prompt_img, model="stabilityai/stable-diffusion-xl-base-1.0")
        nome_arquivo = f"img_{int(time.time())}.jpg"
        caminho_completo = os.path.join(folder, nome_arquivo)
        imagem.save(caminho_completo)
    except Exception as e:
        print(f"Erro na IA de imagem: {e}")
        return

    # 3. TRATAMENTO DOS DADOS
    agora = datetime.now()
    data_formatada = agora.strftime("%d/%m/%Y às %H:%M")
    linhas = [l.strip() for l in resumo_ia.split('\n') if l.strip()]
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

    print(f"\n[SUCESSO LOCAL] Post '{titulo_final}' salvo com sucesso!")

if __name__ == "__main__":
    gerar_e_subir()