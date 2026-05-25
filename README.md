# DevOps Portfolio – Ricardo Oliveira

Welcome to my **DevOps Portfolio** – a curated collection of hands‑on projects that demonstrate the core skills required for the Junior DevOps position at Pantheon Inc.

---

## 🎯 Goal
> Showcase practical experience with **CI/CD**, **Docker**, **Kubernetes**, **IaC (Terraform)**, **AWS**, and **monitoring** (Grafana, Prometheus, Zabbix) while presenting a clean, professional GitHub presence.

---

## 📂 Repository Structure
```
/devops-portfolio
│
├─ 01-docker-multi-container   # Docker + Docker‑Compose + K8s manifests
├─ 02-terraform-aws            # Terraform IaC for AWS (VPC, EC2, RDS, SG)
├─ 03-ci-cd-pipeline           # GitHub Actions CI/CD workflow (ci.yml)
└─ 04-monitoring-stack         # Grafana/Prometheus + Zabbix monitoring stack
```

Each sub‑folder contains a **README.md** with detailed usage instructions, screenshots, and badge badges.

---

## 🛠️ Technologies & Tools
- **Docker** & **Docker‑Compose** – containerisation of a sample Node.js app.
- **Kubernetes** – manifests to deploy the same app in a cluster.
- **Terraform 1.6** – provisioning of a minimal AWS environment (VPC, sub‑nets, security groups, EC2, RDS).
- **GitHub Actions** – automated build, test, Docker‑Hub push, and Terraform apply.
- **Grafana & Prometheus** – observability stack with ready‑made dashboards.
- **Zabbix** – agent‑based host monitoring (included in the monitoring‑stack).
- **AWS Cloud** – the target cloud provider for the role.

---

## 📦 Badges
[![CI](https://github.com/rickOsantos/devops-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/rickOsantos/devops-portfolio/actions/workflows/ci.yml) 
[![Docker Pulls](https://img.shields.io/docker/pulls/rickosantos/devops-portfolio)](https://hub.docker.com/r/rickosantos/devops-portfolio) 
[![Terraform](https://img.shields.io/badge/Terraform-1.6.5-blue.svg)](https://www.terraform.io)

---

## 🚀 Quick Start
```bash
# 1️⃣ Clone the portfolio
git clone https://github.com/rickOsantos/devops-portfolio.git
cd devops-portfolio

# 2️⃣ Run Docker‑Compose (sample app)
cd 01-docker-multi-container
docker compose up -d

# 3️⃣ Deploy to Kubernetes (if you have a cluster)
kubectl apply -f k8s-manifests/

# 4️⃣ Provision AWS infra with Terraform
cd ../02-terraform-aws
terraform init && terraform apply
```

---

## 📚 Documentation & Screenshots
- Each sub‑project includes a dedicated README with step‑by‑step instructions and screenshots of the running application, Terraform plan, and Grafana dashboards.
- Feel free to explore the repository and adapt any component for your own environment.

---

## 🔗 Links
- **GitHub profile:** https://github.com/rickOsantos
- **LinkedIn:** https://www.linkedin.com/in/ricardo-oliveira-tech/
- **Docker Hub:** https://hub.docker.com/u/rickosantos

---

## 📈 How this portfolio matches the Pantheon Inc Junior DevOps role
| Requirement | How the portfolio satisfies it |
|------------|--------------------------------|
| CI/CD pipelines (GitHub Actions / GitLab) | `03-ci-cd-pipeline/.github/workflows/ci.yml` builds Docker images, pushes to Docker Hub, runs Terraform and deploys to K8s. |
| Docker & containerisation | `01-docker-multi-container` contains a Dockerfile, Docker‑Compose and K8s manifests. |
| Kubernetes orchestration | K8s manifests ready for `kubectl apply`. |
| IaC with Terraform | `02-terraform-aws` provisions a full AWS environment (VPC, EC2, RDS). |
| Monitoring (Grafana, Prometheus, Zabbix) | `04-monitoring-stack` includes Grafana dashboards, Prometheus scrapers and a Zabbix server setup. |
| Cloud (AWS) | Terraform scripts target AWS; Docker images can be deployed to AWS ECS/EKS. |
| Networking (TCP/IP, sub‑nets, SG) | Terraform defines VPC CIDR, sub‑nets and security groups. |

---

## 🎉 Ready to impress?
Use this portfolio as a concrete demonstration of your DevOps capabilities in interviews and on your résumé. Update the README with any personal touches, push the code, and share the link on your LinkedIn profile.

---

*All code is open‑source and released under the MIT License.*
