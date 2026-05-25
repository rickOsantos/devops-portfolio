#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Executa todos os testes"
    echo "  -p, --prometheus   Testa Prometheus"
    echo "  -g, --grafana      Testa Grafana"
    echo "  -e, --elk          Testa ELK"
    echo "  -i, --integration  Testa integrações"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para testar Prometheus
test_prometheus() {
    echo "Testando Prometheus..."
    
    # Verifica status
    if ! curl -s http://localhost:9090/api/v1/status/buildinfo &> /dev/null; then
        echo "❌ Prometheus NÃO está rodando"
        return
    fi
    
    # Testa métricas
    metrics=$(curl -s http://localhost:9090/api/v1/query?query=up)
    if ! echo "$metrics" | grep -q '"value":1'; then
        echo "❌ Métricas indisponíveis"
        return
    fi
    
    # Testa alertas
    alerts=$(curl -s http://localhost:9090/api/v1/alerts)
    if echo "$alerts" | grep -q '"state":"firing"'; then
        echo "⚠️ Alertas em estado firing"
    fi
    
    echo "✅ Testes do Prometheus concluídos com sucesso!"
}

# Função para testar Grafana
test_grafana() {
    echo "Testando Grafana..."
    
    # Verifica status
    if ! curl -s http://localhost:3000/api/health &> /dev/null; then
        echo "❌ Grafana NÃO está rodando"
        return
    fi
    
    # Testa dashboards
    dashboards=$(curl -s -u admin:admin http://localhost:3000/api/search | grep "title")
    if [ -z "$dashboards" ]; then
        echo "❌ Dashboards não encontrados"
        return
    fi
    
    # Testa plugins
    plugins=$(curl -s -u admin:admin http://localhost:3000/api/plugins | grep "name")
    if [ -z "$plugins" ]; then
        echo "❌ Plugins não encontrados"
        return
    fi
    
    echo "✅ Testes do Grafana concluídos com sucesso!"
}

# Função para testar ELK
test_elk() {
    echo "Testando ELK..."
    
    # Testa Elasticsearch
    es_status=$(curl -s http://localhost:9200/_cluster/health | grep "status")
    if echo "$es_status" | grep -q '"status":"red"'; then
        echo "❌ Elasticsearch em estado crítico"
        return
    fi
    
    # Testa Kibana
    if ! curl -s http://localhost:5601/api/status &> /dev/null; then
        echo "❌ Kibana NÃO está rodando"
        return
    fi
    
    # Testa Logstash
    if ! docker logs --tail 10 logstash 2>&1 | grep -q "Pipeline main started"; then
        echo "❌ Logstash NÃO está funcionando"
        return
    fi
    
    echo "✅ Testes do ELK concluídos com sucesso!"
}

# Função para testar integrações
test_integrations() {
    echo "Testando integrações..."
    
    # Testa Prometheus com Grafana
    if ! curl -s -u admin:admin http://localhost:3000/api/datasources/name/Prometheus | grep -q "Prometheus"; then
        echo "❌ Integração Prometheus-Grafana falhou"
        return
    fi
    
    # Testa Logstash com Elasticsearch
    if ! curl -s http://localhost:9200/_cat/indices | grep -q "app-logs"; then
        echo "❌ Integração Logstash-Elasticsearch falhou"
        return
    fi
    
    # Testa Kibana com Elasticsearch
    if ! curl -s http://localhost:5601/api/saved_objects/_find | grep -q "app-logs"; then
        echo "❌ Integração Kibana-Elasticsearch falhou"
        return
    fi
    
    echo "✅ Testes de integração concluídos com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            test_prometheus
            test_grafana
            test_elk
            test_integrations
            exit 0
            ;;
        -p|--prometheus)
            test_prometheus
            exit 0
            ;;
        -g|--grafana)
            test_grafana
            exit 0
            ;;
        -e|--elk)
            test_elk
            exit 0
            ;;
        -i|--integration)
            test_integrations
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
