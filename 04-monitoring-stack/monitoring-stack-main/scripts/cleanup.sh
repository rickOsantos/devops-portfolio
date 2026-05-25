#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Remove todo o stack"
    echo "  -p, --prometheus   Remove apenas o Prometheus"
    echo "  -g, --grafana      Remove apenas o Grafana"
    echo "  -e, --elk          Remove apenas a pilha ELK"
    echo "  -d, --data         Remove apenas os dados"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para remover containers
remove_containers() {
    echo "Removendo containers..."
    docker-compose down
    
    # Remove volumes
    docker volume prune -f
    
    echo "Containers removidos com sucesso!"
}

# Função para remover dados
remove_data() {
    echo "Removendo dados..."
    
    # Remove volumes do Docker
    docker volume rm $(docker volume ls -q)
    
    # Remove diretórios de dados
    rm -rf prometheus/data
    rm -rf grafana/data
    rm -rf elk/elasticsearch/data
    
    echo "Dados removidos com sucesso!"
}

# Função para remover configurações
remove_configs() {
    echo "Removendo configurações..."
    
    # Remove arquivos de configuração
    rm -f prometheus/prometheus.yml
    rm -f prometheus/alerts.yml
    rm -rf grafana/dashboards
    rm -rf grafana/datasources
    rm -f elk/logstash/pipeline.conf
    
    echo "Configurações removidas com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            remove_containers
            remove_data
            remove_configs
            exit 0
            ;;
        -p|--prometheus)
            remove_containers
            remove_data
            rm -f prometheus/prometheus.yml
            rm -f prometheus/alerts.yml
            exit 0
            ;;
        -g|--grafana)
            remove_containers
            remove_data
            rm -rf grafana/dashboards
            rm -rf grafana/datasources
            exit 0
            ;;
        -e|--elk)
            remove_containers
            remove_data
            rm -f elk/logstash/pipeline.conf
            exit 0
            ;;
        -d|--data)
            remove_data
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
