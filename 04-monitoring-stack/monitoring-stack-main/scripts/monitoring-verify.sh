#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Verifica toda a infraestrutura"
    echo "  -p, --prometheus   Verifica Prometheus"
    echo "  -g, --grafana      Verifica Grafana"
    echo "  -e, --elk          Verifica ELK"
    echo "  -c, --connections  Verifica conexões"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para verificar Prometheus
verify_prometheus() {
    echo "Verificando Prometheus..."
    
    # Verifica status do serviço
    if ! docker ps --filter name=prometheus --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Prometheus NÃO está rodando"
        return
    fi
    
    # Verifica métricas
    metrics=$(curl -s http://localhost:9090/api/v1/query?query=up)
    if ! echo "$metrics" | grep -q '"value":1'; then
        echo "❌ Métricas indisponíveis"
        return
    fi
    
    # Verifica configuração
    config=$(docker exec prometheus cat /etc/prometheus/prometheus.yml)
    if [ -z "$config" ]; then
        echo "❌ Configuração não encontrada"
        return
    fi
    
    echo "✅ Prometheus verificado com sucesso!"
}

# Função para verificar Grafana
verify_grafana() {
    echo "Verificando Grafana..."
    
    # Verifica status do serviço
    if ! docker ps --filter name=grafana --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Grafana NÃO está rodando"
        return
    fi
    
    # Verifica dashboards
    dashboards=$(curl -s -u admin:admin http://localhost:3000/api/search | grep "title")
    if [ -z "$dashboards" ]; then
        echo "❌ Dashboards não encontrados"
        return
    fi
    
    # Verifica plugins
    plugins=$(curl -s -u admin:admin http://localhost:3000/api/plugins | grep "name")
    if [ -z "$plugins" ]; then
        echo "❌ Plugins não encontrados"
        return
    fi
    
    echo "✅ Grafana verificado com sucesso!"
}

# Função para verificar ELK
verify_elk() {
    echo "Verificando ELK..."
    
    # Verifica Elasticsearch
    es_status=$(curl -s http://localhost:9200/_cluster/health | grep "status")
    if echo "$es_status" | grep -q '"status":"red"'; then
        echo "❌ Elasticsearch em estado crítico"
        return
    fi
    
    # Verifica Kibana
    if ! docker ps --filter name=kibana --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Kibana NÃO está rodando"
        return
    fi
    
    # Verifica Logstash
    if ! docker logs --tail 10 logstash 2>&1 | grep -q "Pipeline main started"; then
        echo "❌ Logstash NÃO está funcionando"
        return
    fi
    
    echo "✅ ELK verificado com sucesso!"
}

# Função para verificar conexões
verify_connections() {
    echo "Verificando conexões..."
    
    # Verifica conexão Prometheus-Grafana
    if ! curl -s -u admin:admin http://localhost:3000/api/datasources/name/Prometheus | grep -q "Prometheus"; then
        echo "❌ Conexão Prometheus-Grafana falhou"
        return
    fi
    
    # Verifica conexão Logstash-Elasticsearch
    if ! curl -s http://localhost:9200/_cat/indices | grep -q "app-logs"; then
        echo "❌ Conexão Logstash-Elasticsearch falhou"
        return
    fi
    
    # Verifica conexão Kibana-Elasticsearch
    if ! curl -s http://localhost:5601/api/saved_objects/_find | grep -q "app-logs"; then
        echo "❌ Conexão Kibana-Elasticsearch falhou"
        return
    fi
    
    echo "✅ Conexões verificadas com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            verify_prometheus
            verify_grafana
            verify_elk
            verify_connections
            exit 0
            ;;
        -p|--prometheus)
            verify_prometheus
            exit 0
            ;;
        -g|--grafana)
            verify_grafana
            exit 0
            ;;
        -e|--elk)
            verify_elk
            exit 0
            ;;
        -c|--connections)
            verify_connections
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
