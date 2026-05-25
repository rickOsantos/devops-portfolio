#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todas as métricas"
    echo "  -s, --system       Configura métricas do sistema"
    echo "  -a, --app          Configura métricas da aplicação"
    echo "  -n, --network      Configura métricas de rede"
    echo "  -c, --custom       Configura métricas personalizadas"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar métricas do sistema
setup_system_metrics() {
    echo "Configurando métricas do sistema..."
    
    # Cria configuração de métricas do sistema
    cat << EOF > prometheus/system-metrics.yml
# Métricas do sistema
- job_name: 'system'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path

# Métricas de CPU
- job_name: 'cpu'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: node_cpu_seconds_total
      target_label: cpu_metric

# Métricas de memória
- job_name: 'memory'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: node_memory_
      target_label: memory_metric
EOF
    
    echo "Métricas do sistema configuradas com sucesso!"
}

# Função para configurar métricas da aplicação
setup_app_metrics() {
    echo "Configurando métricas da aplicação..."
    
    # Cria configuração de métricas da aplicação
    cat << EOF > prometheus/app-metrics.yml
# Métricas da aplicação
- job_name: 'app'
  static_configs:
    - targets: ['app-service:8080']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path

# Métricas de requisições HTTP
- job_name: 'http_requests'
  static_configs:
    - targets: ['app-service:8080']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: http_requests_
      target_label: http_metric

# Métricas de latência
- job_name: 'latency'
  static_configs:
    - targets: ['app-service:8080']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: request_duration_
      target_label: latency_metric
EOF
    
    echo "Métricas da aplicação configuradas com sucesso!"
}

# Função para configurar métricas de rede
setup_network_metrics() {
    echo "Configurando métricas de rede..."
    
    # Cria configuração de métricas de rede
    cat << EOF > prometheus/network-metrics.yml
# Métricas de rede
- job_name: 'network'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path

# Métricas de tráfego de rede
- job_name: 'network_traffic'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: node_network_
      target_label: network_metric

# Métricas de conexões
- job_name: 'connections'
  static_configs:
    - targets: ['localhost:9100']
  metrics_path: /metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: node_connections_
      target_label: connection_metric
EOF
    
    echo "Métricas de rede configuradas com sucesso!"
}

# Função para configurar métricas personalizadas
setup_custom_metrics() {
    echo "Configurando métricas personalizadas..."
    
    # Cria configuração de métricas personalizadas
    cat << EOF > prometheus/custom-metrics.yml
# Métricas personalizadas
- job_name: 'custom'
  static_configs:
    - targets: ['localhost:9091']
  metrics_path: /custom_metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path

# Métricas de negócios
- job_name: 'business_metrics'
  static_configs:
    - targets: ['localhost:9091']
  metrics_path: /business_metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: business_
      target_label: business_metric

# Métricas de qualidade
- job_name: 'quality_metrics'
  static_configs:
    - targets: ['localhost:9091']
  metrics_path: /quality_metrics
  scrape_interval: 15s
  scrape_timeout: 10s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: quality_
      target_label: quality_metric
EOF
    
    echo "Métricas personalizadas configuradas com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_system_metrics
            setup_app_metrics
            setup_network_metrics
            setup_custom_metrics
            exit 0
            ;;
        -s|--system)
            setup_system_metrics
            exit 0
            ;;
        -a|--app)
            setup_app_metrics
            exit 0
            ;;
        -n|--network)
            setup_network_metrics
            exit 0
            ;;
        -c|--custom)
            setup_custom_metrics
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
