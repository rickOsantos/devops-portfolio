#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Realiza todas as verificações de troubleshooting"
    echo "  -p, --prometheus   Verifica problemas do Prometheus"
    echo "  -g, --grafana      Verifica problemas do Grafana"
    echo "  -e, --elk          Verifica problemas do ELK"
    echo "  -l, --logs         Verifica logs de erros"
    echo "  -m, --metrics      Verifica métricas problemáticas"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para verificar problemas do Prometheus
check_prometheus() {
    echo "Verificando problemas do Prometheus..."
    
    # Verifica status do serviço
    if ! curl -s http://localhost:9090/api/v1/status/buildinfo &> /dev/null; then
        echo "❌ Prometheus NÃO está rodando"
        return
    fi
    
    # Verifica métricas
    metrics=$(curl -s http://localhost:9090/api/v1/query?query=up)
    if echo "$metrics" | grep -q '"value":0'; then
        echo "❌ Métricas indisponíveis"
    fi
    
    # Verifica logs de erro
    docker logs --tail 100 prometheus 2>&1 | grep -i "error|fail"
    
    echo "Verificação do Prometheus concluída!"
}

# Função para verificar problemas do Grafana
check_grafana() {
    echo "Verificando problemas do Grafana..."
    
    # Verifica status do serviço
    if ! curl -s http://localhost:3000/api/health &> /dev/null; then
        echo "❌ Grafana NÃO está rodando"
        return
    fi
    
    # Verifica dashboards
    dashboards=$(curl -s -u admin:admin http://localhost:3000/api/search | grep "title")
    if [ -z "$dashboards" ]; then
        echo "❌ Dashboards não encontrados"
    fi
    
    # Verifica logs de erro
    docker logs --tail 100 grafana 2>&1 | grep -i "error|fail"
    
    echo "Verificação do Grafana concluída!"
}

# Função para verificar problemas do ELK
check_elk() {
    echo "Verificando problemas do ELK..."
    
    # Verifica Elasticsearch
    es_status=$(curl -s http://localhost:9200/_cluster/health | grep "status")
    if echo "$es_status" | grep -q '"status":"red"'; then
        echo "❌ Elasticsearch em estado crítico"
    fi
    
    # Verifica Kibana
    if ! curl -s http://localhost:5601/api/status &> /dev/null; then
        echo "❌ Kibana NÃO está rodando"
        return
    fi
    
    # Verifica logs de erro
    docker logs --tail 100 elasticsearch 2>&1 | grep -i "error|fail"
    docker logs --tail 100 kibana 2>&1 | grep -i "error|fail"
    
    echo "Verificação do ELK concluída!"
}

# Função para verificar logs de erro
check_error_logs() {
    echo "Verificando logs de erro..."
    
    # Verifica logs de erro do sistema
    journalctl -u prometheus -u grafana -u elasticsearch -u kibana --no-pager | grep -i "error|fail"
    
    # Verifica logs de erro dos containers
    docker logs --tail 100 $(docker ps -q --filter name=prometheus) 2>&1 | grep -i "error|fail"
    docker logs --tail 100 $(docker ps -q --filter name=grafana) 2>&1 | grep -i "error|fail"
    docker logs --tail 100 $(docker ps -q --filter name=elasticsearch) 2>&1 | grep -i "error|fail"
    docker logs --tail 100 $(docker ps -q --filter name=kibana) 2>&1 | grep -i "error|fail"
    
    echo "Verificação de logs concluída!"
}

# Função para verificar métricas problemáticas
check_problem_metrics() {
    echo "Verificando métricas problemáticas..."
    
    # Verifica CPU alta
    cpu=$(curl -s http://localhost:9090/api/v1/query?query=rate(process_cpu_seconds_total[5m]) > 0.8)
    if [ "$cpu" = "true" ]; then
        echo "⚠️ CPU alta detectada"
    fi
    
    # Verifica memória alta
    memory=$(curl -s http://localhost:9090/api/v1/query?query=process_resident_memory_bytes > 1000000000)
    if [ "$memory" = "true" ]; then
        echo "⚠️ Memória alta detectada"
    fi
    
    # Verifica taxa de erro alta
    error_rate=$(curl -s http://localhost:9090/api/v1/query?query=rate(http_requests_total{job="app", status=~"5.."}[5m]) / rate(http_requests_total{job="app"}[5m]) > 0.1)
    if [ "$error_rate" = "true" ]; then
        echo "⚠️ Taxa de erro alta detectada"
    fi
    
    echo "Verificação de métricas concluída!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            check_prometheus
            check_grafana
            check_elk
            check_error_logs
            check_problem_metrics
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
        -l|--logs)
            check_error_logs
            exit 0
            ;;
        -m|--metrics)
            check_problem_metrics
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
