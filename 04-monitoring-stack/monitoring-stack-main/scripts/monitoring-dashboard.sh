#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Abre todos os dashboards"
    echo "  -p, --prometheus   Abre o Prometheus"
    echo "  -g, --grafana      Abre o Grafana"
    echo "  -e, --elk          Abre o Kibana"
    echo "  -l, --logs         Abre logs do ELK"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para abrir Prometheus
open_prometheus() {
    echo "Abrindo Prometheus..."
    
    # Verifica se o Prometheus está rodando
    if ! curl -s http://localhost:9090/api/v1/status/buildinfo &> /dev/null; then
        echo "Prometheus não está rodando. Por favor, inicie o stack primeiro."
        exit 1
    fi
    
    # Abre no navegador
    xdg-open http://localhost:9090
    
    echo "Prometheus aberto no navegador!"
}

# Função para abrir Grafana
open_grafana() {
    echo "Abrindo Grafana..."
    
    # Verifica se o Grafana está rodando
    if ! curl -s http://localhost:3000/api/health &> /dev/null; then
        echo "Grafana não está rodando. Por favor, inicie o stack primeiro."
        exit 1
    fi
    
    # Abre no navegador
    xdg-open http://localhost:3000
    
    echo "Grafana aberto no navegador!"
    echo "Login padrão: admin/admin"
}

# Função para abrir Kibana
open_kibana() {
    echo "Abrindo Kibana..."
    
    # Verifica se o Kibana está rodando
    if ! curl -s http://localhost:5601/api/status &> /dev/null; then
        echo "Kibana não está rodando. Por favor, inicie o stack primeiro."
        exit 1
    fi
    
    # Abre no navegador
    xdg-open http://localhost:5601
    
    echo "Kibana aberto no navegador!"
}

# Função para visualizar logs
view_logs() {
    echo "Visualizando logs..."
    
    # Verifica se o Elasticsearch está rodando
    if ! curl -s http://localhost:9200/_cluster/health &> /dev/null; then
        echo "Elasticsearch não está rodando. Por favor, inicie o stack primeiro."
        exit 1
    fi
    
    # Mostra logs recentes
    curl -s http://localhost:9200/_search?q=service:app | jq '.hits.hits[] | {timestamp: ._source.@timestamp, level: ._source.log_level, message: ._source.log_message}'
    
    echo "Logs exibidos!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            open_prometheus
            open_grafana
            open_kibana
            view_logs
            exit 0
            ;;
        -p|--prometheus)
            open_prometheus
            exit 0
            ;;
        -g|--grafana)
            open_grafana
            exit 0
            ;;
        -e|--elk)
            open_kibana
            exit 0
            ;;
        -l|--logs)
            view_logs
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
