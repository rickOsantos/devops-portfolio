#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura toda a integração"
    echo "  -p, --prometheus   Configura integração com Prometheus"
    echo "  -g, --grafana      Configura integração com Grafana"
    echo "  -e, --elk          Configura integração com ELK"
    echo "  -s, --slack        Configura notificações para Slack"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar integração com Prometheus
setup_prometheus_integration() {
    echo "Configurando integração com Prometheus..."
    
    # Cria configuração de scrape
    cat << EOF > prometheus/scrape-config.yml
scrape_configs:
  - job_name: 'app-metrics'
    static_configs:
      - targets: ['app-service:8080']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - source_labels: [__address__]
        replacement: kubernetes.default.svc:80
        target_label: __address__
      - source_labels: [__meta_kubernetes_node_name]
        target_label: node
EOF
    
    echo "Integração com Prometheus configurada com sucesso!"
}

# Função para configurar integração com Grafana
setup_grafana_integration() {
    echo "Configurando integração com Grafana..."
    
    # Cria configuração de datasource
    cat << EOF > grafana/datasources/prometheus-ds.yml
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
    
    echo "Integração com Grafana configurada com sucesso!"
}

# Função para configurar integração com ELK
setup_elk_integration() {
    echo "Configurando integração com ELK..."
    
    # Cria configuração de Logstash
    cat << EOF > elk/logstash/input.conf
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
EOF
    
    echo "Integração com ELK configurada com sucesso!"
}

# Função para configurar notificações para Slack
setup_slack_integration() {
    echo "Configurando notificações para Slack..."
    
    # Cria configuração de webhook
    cat << EOF > slack/webhook-config.yml
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
channel: "#alerts"
username: "Monitoring Bot"
icon_emoji: ":warning:"
EOF
    
    # Cria configuração de alertas
    cat << EOF > slack/alerts-config.yml
alerts:
  - name: "High CPU Usage"
    webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    channel: "#alerts"
    message: "High CPU usage detected on {{ .Labels.instance }}"

  - name: "Error Rate"
    webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    channel: "#alerts"
    message: "Error rate above threshold on {{ .Labels.instance }}"
EOF
    
    echo "Notificações para Slack configuradas com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_prometheus_integration
            setup_grafana_integration
            setup_elk_integration
            setup_slack_integration
            exit 0
            ;;
        -p|--prometheus)
            setup_prometheus_integration
            exit 0
            ;;
        -g|--grafana)
            setup_grafana_integration
            exit 0
            ;;
        -e|--elk)
            setup_elk_integration
            exit 0
            ;;
        -s|--slack)
            setup_slack_integration
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
