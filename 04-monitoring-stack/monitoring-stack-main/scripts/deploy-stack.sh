#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Instala todo o stack"
    echo "  -p, --prometheus   Instala apenas o Prometheus"
    echo "  -g, --grafana      Instala apenas o Grafana"
    echo "  -e, --elk          Instala apenas a pilha ELK"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para instalar Prometheus
install_prometheus() {
    echo "Instalando Prometheus..."
    
    # Verifica se Docker está instalado
    if ! command -v docker &> /dev/null; then
        echo "Docker não está instalado. Por favor, instale primeiro."
        exit 1
    fi
    
    # Cria diretórios necessários
    mkdir -p prometheus
    
    # Copia configurações
    cp ../prometheus/prometheus.yml .
    cp ../prometheus/alerts.yml .
    
    echo "Prometheus instalado com sucesso!"
}

# Função para instalar Grafana
install_grafana() {
    echo "Instalando Grafana..."
    
    # Cria diretórios necessários
    mkdir -p grafana/dashboards grafana/datasources
    
    # Copia configurações
    cp ../grafana/dashboards/* grafana/dashboards/
    cp ../grafana/datasources/* grafana/datasources/
    
    echo "Grafana instalado com sucesso!"
}

# Função para instalar ELK
install_elk() {
    echo "Instalando ELK..."
    
    # Cria diretórios necessários
    mkdir -p elk/elasticsearch elk/logstash elk/kibana
    
    # Copia configurações
    cp ../elk/logstash/pipeline.conf elk/logstash/
    
    echo "ELK instalado com sucesso!"
}

# Função para iniciar o stack
start_stack() {
    echo "Iniciando o stack..."
    
    # Inicia os containers
    docker-compose up -d
    
    # Verifica status
    docker-compose ps
    
    echo "Stack iniciado com sucesso!"
    echo "Acesse:"
    echo "- Prometheus: http://localhost:9090"
    echo "- Grafana: http://localhost:3000"
    echo "- Kibana: http://localhost:5601"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            install_prometheus
            install_grafana
            install_elk
            start_stack
            exit 0
            ;;
        -p|--prometheus)
            install_prometheus
            exit 0
            ;;
        -g|--grafana)
            install_grafana
            exit 0
            ;;
        -e|--elk)
            install_elk
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
