# DevOps Portfolio – Ricardo Oliveira

Bem-vindo ao meu **Portfólio DevOps** – uma coleção selecionada de projetos práticos que demonstram as principais habilidades necessárias para uma posição em DevOps.

---

## 🎯 Objetivo
> Demonstrar experiência prática com **CI/CD**, **Docker**, **Kubernetes**, **IaC (Terraform)**, **AWS** e **monitoramento** (Grafana, Prometheus, Zabbix), mantendo uma presença profissional e organizada no GitHub.

---

## 📂 Estrutura do Repositório

```text
/devops-portfolio
│
├─ 01-docker-multi-container   # Docker + Docker-Compose + manifests Kubernetes
├─ 02-terraform-aws            # IaC com Terraform para AWS (VPC, EC2, RDS, SG)
├─ 03-ci-cd-pipeline           # Pipeline CI/CD com GitHub Actions (ci.yml)
└─ 04-monitoring-stack         # Stack de monitoramento Grafana/Prometheus + Zabbix
```

Cada subpasta contém um arquivo **README.md** com instruções detalhadas de uso, capturas de tela e badges.

---

## 🛠️ Tecnologias & Ferramentas

- **Docker** & **Docker-Compose** – conteinerização de uma aplicação exemplo em Node.js.
- **Kubernetes** – manifests para implantação da mesma aplicação em um cluster.
- **Terraform 1.6** – provisionamento de um ambiente AWS mínimo (VPC, sub-redes, grupos de segurança, EC2 e RDS).
- **GitHub Actions** – automação de build, testes, push para Docker Hub e aplicação do Terraform.
- **Grafana & Prometheus** – stack de observabilidade com dashboards prontos.
- **Zabbix** – monitoramento baseado em agentes para hosts.
- **AWS Cloud** – principal provedor de nuvem utilizado no projeto.

---

## 📦 Badges

[![CI](https://github.com/rickOsantos/devops-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/rickOsantos/devops-portfolio/actions/workflows/ci.yml)

[![Docker Pulls](https://img.shields.io/docker/pulls/rickosantos/devops-portfolio)](https://hub.docker.com/r/rickosantos/devops-portfolio)

[![Terraform](https://img.shields.io/badge/Terraform-1.6.5-blue.svg)](https://www.terraform.io)

---

## 🚀 Início Rápido

```bash
# 1️⃣ Clonar o portfólio
git clone https://github.com/rickOsantos/devops-portfolio.git
cd devops-portfolio

# 2️⃣ Executar o Docker-Compose (aplicação exemplo)
cd 01-docker-multi-container
docker compose up -d

# 3️⃣ Fazer deploy no Kubernetes (caso possua um cluster)
kubectl apply -f k8s-manifests/

# 4️⃣ Provisionar infraestrutura AWS com Terraform
cd ../02-terraform-aws
terraform init && terraform apply
```

---

## 📚 Documentação & Capturas de Tela

- Cada subprojeto possui um README dedicado com instruções passo a passo e capturas de tela da aplicação em execução, plano do Terraform e dashboards do Grafana.
- Sinta-se à vontade para explorar o repositório e adaptar qualquer componente ao seu próprio ambiente.

---

## 🔗 Links

- **GitHub profile:** https://github.com/rickOsantos
- **LinkedIn:** https://www.linkedin.com/in/ricardo-oliveira-tech/
- **Docker Hub:** https://hub.docker.com/u/rickosantos

---

## 📈 Como este portfólio atende à vaga de Junior DevOps

| Requisito | Como o portfólio atende |
|------------|--------------------------------|
| Pipelines CI/CD (GitHub Actions / GitLab) | `03-ci-cd-pipeline/.github/workflows/ci.yml` realiza build de imagens Docker, push para Docker Hub, execução do Terraform e deploy em Kubernetes. |
| Docker & conteinerização | `01-docker-multi-container` contém Dockerfile, Docker-Compose e manifests Kubernetes. |
| Orquestração com Kubernetes | Manifests Kubernetes prontos para uso com `kubectl apply`. |
| IaC com Terraform | `02-terraform-aws` provisiona um ambiente completo na AWS (VPC, EC2, RDS). |
| Monitoramento (Grafana, Prometheus, Zabbix) | `04-monitoring-stack` inclui dashboards Grafana, scrapers Prometheus e configuração do Zabbix. |
| Cloud (AWS) | Scripts Terraform utilizam AWS; imagens Docker podem ser implantadas em ECS/EKS. |
| Redes (TCP/IP, sub-redes, Security Groups) | Terraform define CIDR da VPC, sub-redes e grupos de segurança. |

---

## 🎉 Pronto para impressionar?

Utilize este portfólio como uma demonstração concreta das suas habilidades em DevOps em entrevistas e no currículo. Atualize o README com toques pessoais, publique o código e compartilhe o link no LinkedIn.

---

## 📄 Licença

Todo o código é open source e distribuído sob a licença MIT.
