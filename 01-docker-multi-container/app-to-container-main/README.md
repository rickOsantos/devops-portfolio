# Aplicação Node.js em Contêiner

Este projeto demonstra como empacotar uma aplicação Node.js em um contêiner Docker. A aplicação é uma API REST simples que pode ser executada em qualquer ambiente suportando Docker.

## Funcionalidades

- API REST com Express.js
- Suporte a variáveis de ambiente
- Health check
- Teste de ambiente
- Containerização com Docker

## Pré-requisitos

- Node.js >= 18.x
- Docker

## Como Usar

### 1. Build do Contêiner

```bash
docker build -t node-app-container .
```

### 2. Executar o Contêiner

```bash
docker run -d -p 3000:3000 --name node-app node-app-container
```

### 3. Testar a Aplicação

Acesse as seguintes rotas:

- `http://localhost:3000/` - Página principal
- `http://localhost:3000/health` - Health check
- `http://localhost:3000/env` - Visualizar variáveis de ambiente

## Estrutura do Projeto

- `app.js` - Arquivo principal da aplicação
- `package.json` - Dependências e scripts
- `Dockerfile` - Configuração do contêiner
- `.dockerignore` - Arquivos ignorados no build do Docker

## Variáveis de Ambiente

- `PORT` - Porta da aplicação (padrão: 3000)
- `NODE_ENV` - Ambiente (development/production)

## Build Multi-stage

O Dockerfile utiliza uma imagem base leve (node:18-alpine) e inclui apenas as dependências necessárias para produção.

## Melhores Práticas Implementadas

- Uso de .dockerignore para otimizar o build
- Separação clara de dependências de desenvolvimento e produção
- Exposição de porta padrão
- Suporte a variáveis de ambiente
- Health check integrado
- Logs estruturados

## Testando o Contêiner

Para testar o contêiner localmente:

```bash
# Build
docker build -t node-app-container .

# Executar
docker run -d -p 3000:3000 --name node-app node-app-container

# Verificar logs
docker logs node-app

# Testar API
curl http://localhost:3000/
```

## Removendo o Contêiner

```bash
docker stop node-app
docker rm node-app
```

## Notas

- A aplicação está configurada para rodar em modo de desenvolvimento por padrão
- O contêiner é otimizado para produção
- Todas as dependências são instaladas automaticamente durante o build
