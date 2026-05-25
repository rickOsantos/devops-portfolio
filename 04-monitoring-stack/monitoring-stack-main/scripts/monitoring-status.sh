#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Mostra status completo do stack"
    echo "  -p, --prometheus   Mostra status do Prometheus"
    echo "  -g, --grafana      Mostra status do Grafana"
    echo "  -e, --elk          Mostra status do ELK"
    echo "  -c, --containers   Mostra status dos containers"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para verificar status do Prometheus
check_prometheus() {
    echo "Verificando status do Prometheus..."
    
    # Verifica se o serviço está rodando
    if ! curl -s http://localhost:9090/api/v1/status/buildinfo &> /dev/null; then
        echo "❌ Prometheus NÃO está rodando"
        return
    fi
    
    # Verifica métricas
    metrics=$(curl -s http://localhost:9090/api/v1/query?query=up)
    if echo "$metrics" | grep -q '"value":1'; then
        echo "✅ Prometheus está rodando"
        echo "✅ Métricas disponíveis"
    else
        echo "❌ Métricas NÃO disponíveis"
    fi
}

# Função para verificar status do Grafana
check_grafana() {
    echo "\nVerificando status do Grafana..."
    
    # Verifica se o serviço está rodando
    if ! curl -s http://localhost:3000/api/health &> /dev/null; then
        echo "❌ Grafana NÃO está rodando"
        return
    fi
    
    # Verifica dashboards
    dashboards=$(curl -s -u admin:admin http://localhost:3000/api/search | grep "title")
    if [ -n "$dashboards" ]; then
        echo "✅ Grafana está rodando"
        echo "✅ Dashboards disponíveis"
    else
        echo "❌ Dashboards NÃO disponíveis"
    fi
}

# Função para verificar status do ELK
check_elk() {
    echo "\nVerificando status do ELK..."
    
    # Verifica Elasticsearch
    es_status=$(curl -s http://localhost:9200/_cluster/health | grep "status")
    if echo "$es_status" | grep -q '"status":"green"'; then
        echo "✅ Elasticsearch está OK"
    else
        echo "❌ Elasticsearch NÃO está OK"
    fi
    
    # Verifica Kibana
    if ! curl -s http://localhost:5601/api/status &> /dev/null; then
        echo "❌ Kibana NÃO está rodando"
        return
    fi
    
    echo "✅ Kibana está rodando"
}

# Função para verificar status dos containers
check_containers() {
    echo "\nVerificando status dos containers..."
    
    # Lista containers
    docker ps --format "{{.Names}}\t{{.Status}}" | grep -E "prometheus|grafana|elasticsearch|kibana|logstash"
    
    # Verifica logs de erro
    echo "\nVerificando logs de erro..."
    docker logs --tail 10 $(docker ps -q --filter name=prometheus) 2>&1 | grep -i "error|fail"
    docker logs --tail 10 $(docker ps -q --filter name=grafana) 2>&1 | grep -i "error|fail"
    docker logs --tail 10 $(docker ps -q --filter name=elasticsearch) 2>&1 | grep -i "error|fail"
    docker logs --tail 10 $(docker ps -q --filter name=kibana) 2>&1 | grep -i "error|fail"
    docker logs --tail 10 $(docker ps -q --filter name=logstash) 2>&1 | grep -i "error|fail"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            check_prometheus
            check_grafana
            check_elk
            check_containers
            exit 0
            ;;
        -p|--prometheus)
            check_prometheus
            exit 0
            ;;
        -g|--grafana)
            check_grafana
            exit 0
            ;;
        -e|--elk)
            check_elk
            exit 0
            ;;
        -c|--containers)
            check_containers
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
