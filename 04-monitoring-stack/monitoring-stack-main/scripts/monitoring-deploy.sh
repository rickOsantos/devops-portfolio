#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Realiza deploy completo"
    echo "  -p, --prometheus   Realiza deploy do Prometheus"
    echo "  -g, --grafana      Realiza deploy do Grafana"
    echo "  -e, --elk          Realiza deploy do ELK"
    echo "  -c, --config       Configura serviços"
    echo "  -d, --dashboard    Configura dashboards"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para realizar deploy do Prometheus
deploy_prometheus() {
    echo "Realizando deploy do Prometheus..."
    
    # Cria configuração
    cat << EOF > prometheus/prometheus.yml
# Configuração do Prometheus
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app'
    static_configs:
      - targets: ['app-service:8080']

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "rules/*.yml"
EOF
    
    # Cria regras de alerta
    mkdir -p prometheus/rules
    cat << EOF > prometheus/rules/app-rules.yml
# Regras de alerta do Prometheus
groups:
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
EOF
    
    echo "Deploy do Prometheus concluído com sucesso!"
}

# Função para realizar deploy do Grafana
deploy_grafana() {
    echo "Realizando deploy do Grafana..."
    
    # Cria configuração
    cat << EOF > grafana/grafana.ini
[server]
http_port = 3000
protocol = http

[security]
admin_user = admin
admin_password = admin

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[analytics]
reporting_enabled = false
check_for_updates = false
EOF
    
    # Cria dashboards
    mkdir -p grafana/dashboards
    cat << EOF > grafana/dashboards/app-performance.json
{
  "title": "App Performance Dashboard",
  "panels": [
    {
      "title": "Overview",
      "type": "row",
      "panels": [
        {
          "title": "CPU Usage",
          "type": "timeseries",
          "datasource": "Prometheus",
          "query": "rate(process_cpu_seconds_total[5m])"
        },
        {
          "title": "Memory Usage",
          "type": "timeseries",
          "datasource": "Prometheus",
          "query": "process_resident_memory_bytes"
        }
      ]
    },
    {
      "title": "Metrics",
      "type": "row",
      "panels": [
        {
          "title": "Request Rate",
          "type": "timeseries",
          "datasource": "Prometheus",
          "query": "rate(http_requests_total[5m])"
        },
        {
          "title": "Error Rate",
          "type": "timeseries",
          "datasource": "Prometheus",
          "query": "rate(http_requests_total{job=\"app\", status=~\"5..\"}[5m]) / rate(http_requests_total{job=\"app\"}[5m])"
        }
      ]
    }
  ]
}
EOF
    
    echo "Deploy do Grafana concluído com sucesso!"
}

# Função para realizar deploy do ELK
deploy_elk() {
    echo "Realizando deploy do ELK..."
    
    # Cria configuração do Elasticsearch
    cat << EOF > elk/elasticsearch.yml
cluster.name: "elasticsearch"
node.name: "elk-node"

network.host: 0.0.0.0
http.port: 9200

xpack.security.enabled: true
xpack.security.http.ssl.enabled: true
EOF
    
    # Cria configuração do Kibana
    cat << EOF > elk/kibana.yml
server.port: 5601
server.host: "0.0.0.0"

elasticsearch.hosts: ["http://elasticsearch:9200"]
xpack.security.enabled: true
EOF
    
    # Cria configuração do Logstash
    cat << EOF > elk/logstash.conf
input {
  file {
    path => "/var/log/app/*.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
    codec => multiline {
      pattern => "^%{TIMESTAMP_ISO8601}"
      negate => true
      what => "previous"
    }
  }
}

filter {
  grok {
    match => {
      "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:log_level} %{DATA:service} %{GREEDYDATA:log_message}"
    }
  }

  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
EOF
    
    echo "Deploy do ELK concluído com sucesso!"
}

# Função para configurar serviços
configure_services() {
    echo "Configurando serviços..."
    
    # Configura Prometheus como datasource do Grafana
    cat << EOF > grafana/datasources/prometheus.yml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    jsonData:
      httpMethod: GET
      timeInterval: "5s"
EOF
    
    # Configura integração com Slack
    cat << EOF > slack/config.yml
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
channel: "#alerts"
username: "Monitoring Bot"
icon_emoji: ":warning:"
EOF
    
    echo "Serviços configurados com sucesso!"
}

# Função para configurar dashboards
configure_dashboards() {
    echo "Configurando dashboards..."
    
    # Cria diretório para dashboards
    mkdir -p grafana/dashboards
    
    # Cria dashboard de logs
    cat << EOF > grafana/dashboards/logs.json
{
  "title": "Logs Dashboard",
  "panels": [
    {
      "title": "Error Logs",
      "type": "timeseries",
      "datasource": "Elasticsearch",
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "log_level": "ERROR"
              }
            }
          ]
        }
      }
    },
    {
      "title": "User Distribution",
      "type": "pie",
      "datasource": "Elasticsearch",
      "aggs": [
        {
          "terms": {
            "field": "user_agent"
          }
        }
      ]
    }
  ]
}
EOF
    
    echo "Dashboards configurados com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            deploy_prometheus
            deploy_grafana
            deploy_elk
            configure_services
            configure_dashboards
            exit 0
            ;;
        -p|--prometheus)
            deploy_prometheus
            exit 0
            ;;
        -g|--grafana)
            deploy_grafana
            exit 0
            ;;
        -e|--elk)
            deploy_elk
            exit 0
            ;;
        -c|--config)
            configure_services
            exit 0
            ;;
        -d|--dashboard)
            configure_dashboards
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
