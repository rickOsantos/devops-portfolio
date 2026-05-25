#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todo o ambiente de desenvolvimento"
    echo "  -d, --docker       Configura Docker e Docker Compose"
    echo "  -k, --k8s          Configura Kubernetes (opcional)"
    echo "  -p, --prometheus   Configura Prometheus"
    echo "  -g, --grafana      Configura Grafana"
    echo "  -e, --elk          Configura ELK"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar Docker
setup_docker() {
    echo "Configurando Docker..."
    
    # Verifica se Docker está instalado
    if ! command -v docker &> /dev/null; then
        echo "Instalando Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        # Adiciona usuário ao grupo docker
        sudo usermod -aG docker $USER
        echo "Por favor, reinicie sua sessão para que as mudanças tenham efeito."
    fi
    
    # Verifica se Docker Compose está instalado
    if ! command -v docker-compose &> /dev/null; then
        echo "Instalando Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    echo "Docker configurado com sucesso!"
}

# Função para configurar Kubernetes
setup_k8s() {
    echo "Configurando Kubernetes..."
    
    # Verifica se kubectl está instalado
    if ! command -v kubectl &> /dev/null; then
        echo "Instalando kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
    
    # Verifica se minikube está instalado
    if ! command -v minikube &> /dev/null; then
        echo "Instalando minikube..."
        curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        chmod +x minikube
        sudo mv minikube /usr/local/bin/
    fi
    
    echo "Kubernetes configurado com sucesso!"
}

# Função para configurar Prometheus
setup_prometheus() {
    echo "Configurando Prometheus..."
    
    # Verifica se o diretório existe
    if [ ! -d "prometheus" ]; then
        mkdir prometheus
    fi
    
    # Copia configurações
    cp ../prometheus/prometheus.yml .
    cp ../prometheus/alerts.yml .
    
    echo "Prometheus configurado com sucesso!"
}

# Função para configurar Grafana
setup_grafana() {
    echo "Configurando Grafana..."
    
    # Verifica se o diretório existe
    if [ ! -d "grafana" ]; then
        mkdir grafana
        mkdir grafana/dashboards
        mkdir grafana/datasources
    fi
    
    # Copia configurações
    cp ../grafana/dashboards/* grafana/dashboards/
    cp ../grafana/datasources/* grafana/datasources/
    
    echo "Grafana configurado com sucesso!"
}

# Função para configurar ELK
setup_elk() {
    echo "Configurando ELK..."
    
    # Verifica se o diretório existe
    if [ ! -d "elk" ]; then
        mkdir elk
        mkdir elk/elasticsearch
        mkdir elk/logstash
        mkdir elk/kibana
    fi
    
    # Copia configurações
    cp ../elk/logstash/pipeline.conf elk/logstash/
    
    echo "ELK configurado com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_docker
            setup_k8s
            setup_prometheus
            setup_grafana
            setup_elk
            exit 0
            ;;
        -d|--docker)
            setup_docker
            exit 0
            ;;
        -k|--k8s)
            setup_k8s
            exit 0
            ;;
        -p|--prometheus)
            setup_prometheus
            exit 0
            ;;
        -g|--grafana)
            setup_grafana
            exit 0
            ;;
        -e|--elk)
            setup_elk
            exit 0
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Opção inválida: $1"
            show_usage
            ;;
    esac
    shift

done

# Se nenhum argumento for fornecido, mostra ajuda
if [[ $# -eq 0 ]]; then
    show_usage
fi
