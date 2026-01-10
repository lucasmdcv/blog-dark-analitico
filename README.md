# 📂 SYSTEM_ROOT | Control Dashboard 🖥️

> **"What you don't measure, you don't control."**
> Interface de comando analítico para geração autônoma de conteúdo via LLM (Llama-3) com monitoramento de pipeline em tempo real.

---

## ⚡ Visão Geral
O **SYSTEM_ROOT** é um ecossistema de automação que permite disparar diretrizes de conteúdo diretamente de um dispositivo móvel (**Moto G42**) para um servidor de processamento em nuvem. O sistema utiliza inteligência artificial para decompor temas complexos em análises técnicas, publicando-as automaticamente em um terminal web otimizado.

## 📱 Interface do Sistema em Operação
<p align="center">
  <img src="dashboard_preview.png" alt="System Root Dashboard and Web Terminal" width="850">
</p>

---

## 🛠️ Arquitetura do Sistema
O projeto é estruturado em três camadas críticas de infraestrutura:

* **Mobile Interface (Flutter):** Dashboard analítico com estética dark, monitoramento de status da API do GitHub e cronômetro de latência.
* **Autonomous Engine (Python + Llama-3):** Script hospedado no GitHub Actions que consome a API do Hugging Face para geração de conteúdo.
* **Deployment (Netlify):** Pipeline de CD (Continuous Deployment) que sincroniza o frontend instantaneamente após a mutação do `post.json`.

---

## 🚀 Funcionalidades Chave
* **Disparo via Dispatch:** Gatilho remoto via API do GitHub sem necessidade de terminal desktop.
* **Monitoramento de Latência:** Cronômetro em tempo real que mede o tempo entre a requisição móvel e a conclusão da Action.
* **Persistência JSON:** Banco de dados leve e eficiente para logs e posts analíticos.
* **Modo Operador:** Injeção de temas aleatórios focados em *Cybersecurity*, *ADS* e *Engenharia de Sistemas*.

---

## 🖥️ Interface de Controle (Métricas)

| Recurso | Descrição Técnico-Analítica |
| :--- | :--- |
| **Motor IA** | Status operacional do modelo Llama-3 (LLM) |
| **Status GH** | Monitoramento de polling via API REST v3 do GitHub |
| **Logs** | Histórico de transmissões e hashes de commit |
| **Barra de Progresso** | Visualização linear do pipeline de CI/CD |

---

## ⚙️ Configuração de Ambiente
Para replicar este terminal de controle, configure o arquivo `.env` no diretório raiz do projeto Flutter:

```env
GITHUB_TOKEN=seu_personal_access_token_aqui
REPO_OWNER=lucasmdcv
REPO_NAME=blog-dark-analitico

![Texto Alternativo](imgreadme.jpg)
