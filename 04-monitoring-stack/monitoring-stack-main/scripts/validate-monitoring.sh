#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Valida todo o stack"
    echo "  -p, --prometheus   Valida Prometheus"
    echo "  -g, --grafana      Valida Grafana"
    echo "  -e, --elk          Valida ELK"
    echo "  -m, --metrics      Valida métricas"
    echo "  -l, --logs         Valida logs"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para validar Prometheus
validate_prometheus() {
    echo "Validando Prometheus..."
    
    # Verifica se o Prometheus está rodando
    curl -s http://localhost:9090/api/v1/status/buildinfo | grep "prometheus"
    
    # Verifica métricas
    curl -s http://localhost:9090/api/v1/query?query=up | grep "value"
    
    echo "Prometheus validado com sucesso!"
}

# Função para validar Grafana
validate_grafana() {
    echo "Validando Grafana..."
    
    # Verifica se o Grafana está rodando
    curl -s http://localhost:3000/api/health | grep "database"
    
    # Verifica dashboards
    curl -s -u admin:admin http://localhost:3000/api/search | grep "title"
    
    echo "Grafana validado com sucesso!"
}

# Função para validar ELK
validate_elk() {
    echo "Validando ELK..."
    
    # Verifica Elasticsearch
    curl -s http://localhost:9200/_cluster/health | grep "status"
    
    # Verifica Kibana
    curl -s http://localhost:5601/api/status | grep "overall"
    
    echo "ELK validado com sucesso!"
}

# Função para validar métricas
validate_metrics() {
    echo "Validando métricas..."
    
    # Verifica métricas do sistema
    curl -s http://localhost:9090/api/v1/query?query=node_cpu_seconds_total | grep "value"
    
    # Verifica métricas da aplicação
    curl -s http://localhost:9090/api/v1/query?query=http_requests_total | grep "value"
    
    echo "Métricas validadas com sucesso!"
}

# Função para validar logs
validate_logs() {
    echo "Validando logs..."
    
    # Verifica logs no Elasticsearch
    curl -s http://localhost:9200/_search?q=service:app | grep "hits"
    
    # Verifica logs de erro
    curl -s http://localhost:9200/_search?q=level:ERROR | grep "hits"
    
    echo "Logs validados com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            validate_prometheus
            validate_grafana
            validate_elk
            validate_metrics
            validate_logs
            exit 0
            ;;
        -p|--prometheus)
            validate_prometheus
            exit 0
            ;;
        -g|--grafana)
            validate_grafana
            exit 0
            ;;
        -e|--elk)
            validate_elk
            exit 0
            ;;
        -m|--metrics)
            validate_metrics
            exit 0
            ;;
        -l|--logs)
            validate_logs
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
