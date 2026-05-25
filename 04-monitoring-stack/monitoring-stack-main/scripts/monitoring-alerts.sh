#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todos os alertas"
    echo "  -p, --prometheus   Configura alertas do Prometheus"
    echo "  -e, --elk          Configura alertas do ELK"
    echo "  -l, --list         Lista todos os alertas"
    echo "  -t, --test         Testa os alertas"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar alertas do Prometheus
setup_prometheus_alerts() {
    echo "Configurando alertas do Prometheus..."
    
    # Cria diretório para alertas
    mkdir -p prometheus/alerts
    
    # Cria regras de alerta
    cat << EOF > prometheus/alerts/alerts.yml
alert_groups:
  - name: app-alerts
    rules:
      - alert: HighCPUUsage
        expr: rate(process_cpu_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"

      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes > 1000000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 1GB"

      - alert: RequestLatencyHigh
        expr: rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m]) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High request latency"
          description: "Average request latency is above 1 second"

      - alert: ErrorRateHigh
        expr: rate(http_requests_total{job="app", status=~"5.."}[5m]) / rate(http_requests_total{job="app"}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate"
          description: "Error rate is above 10%"

      - alert: UnhealthyPods
        expr: kube_pod_status_ready{condition="false"} == 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pods are unhealthy"
          description: "Pods are not in ready state"
EOF

    echo "Alertas do Prometheus configurados com sucesso!"
}

# Função para configurar alertas do ELK
setup_elk_alerts() {
    echo "Configurando alertas do ELK..."
    
    # Cria diretório para alertas
    mkdir -p elk/alerts
    
    # Cria configuração de alerta
    cat << EOF > elk/alerts/error-alerts.yml
alert:
  name: "High Error Rate"
  type: threshold
  index: "app-logs-*"
  threshold:
    max: 10
  time_window:
    minutes: 5
  query:
    query_string:
      query: "log_level:ERROR"
  actions:
    - action:
        email:
          profile: "standard"
          to: "alerts@example.com"
          subject: "High Error Rate Detected"
          body: "Error rate is above threshold"
EOF

    echo "Alertas do ELK configurados com sucesso!"
}

# Função para listar alertas
list_alerts() {
    echo "Listando alertas do Prometheus..."
    curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[] | {name: .name, rules: .rules[] | {alert: .name, description: .annotations.summary}}'
    
    echo "\nListando alertas do ELK..."
    curl -s http://localhost:9200/_watcher/watch | jq '.data.watches[] | {name: .name, description: .metadata.description}'
}

# Função para testar alertas
test_alerts() {
    echo "Testando alertas do Prometheus..."
    # Simula alta CPU
    echo "Simulando alta CPU..."
    stress --cpu 1 --timeout 10s
    
    # Simula erro HTTP
    echo "Simulando erro HTTP..."
    curl -X POST http://localhost:8080/error
    
    echo "\nTestando alertas do ELK..."
    # Gera logs de erro
    echo "Gerando logs de erro..."
    echo "$(date) ERROR app Error occurred in application" >> /var/log/app/error.log
    
    echo "Alertas testados com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_prometheus_alerts
            setup_elk_alerts
            exit 0
            ;;
        -p|--prometheus)
            setup_prometheus_alerts
            exit 0
            ;;
        -e|--elk)
            setup_elk_alerts
            exit 0
            ;;
        -l|--list)
            list_alerts
            exit 0
            ;;
        -t|--test)
            test_alerts
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
