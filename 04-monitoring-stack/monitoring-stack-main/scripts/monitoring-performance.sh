#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura toda a performance"
    echo "  -t, --tuning       Configura otimização"
    echo "  -m, --metrics      Configura métricas de performance"
    echo "  -c, --capacity     Configura capacidade"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar otimização
setup_performance_tuning() {
    echo "Configurando otimização de performance..."
    
    # Cria configuração de otimização
    cat << EOF > prometheus/tuning.yml
# Configuração de otimização
scrape_configs:
  - job_name: 'performance'
    scrape_interval: 10s
    scrape_timeout: 5s
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9090']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance

# Configuração de cache
storage:
  tsdb:
    retention_time: 15d
    min_block_size: 2h
    max_block_size: 2h

# Configuração de compactação
compaction:
  interval: 2h
  min_size: 1GB
  max_size: 10GB

# Configuração de limpeza
cleanup:
  interval: 24h
  retention: 30d
EOF
    
    echo "Otimização de performance configurada com sucesso!"
}

# Função para configurar métricas de performance
setup_performance_metrics() {
    echo "Configurando métricas de performance..."
    
    # Cria configuração de métricas
    cat << EOF > prometheus/performance-metrics.yml
# Métricas de performance
- job_name: 'performance_metrics'
  static_configs:
    - targets: ['localhost:9090']
  metrics_path: /metrics
  scrape_interval: 5s
  scrape_timeout: 3s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance

# Métricas de latência
- job_name: 'latency_metrics'
  static_configs:
    - targets: ['localhost:9090']
  metrics_path: /metrics
  scrape_interval: 5s
  scrape_timeout: 3s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: request_duration_
      target_label: latency_metric

# Métricas de throughput
- job_name: 'throughput_metrics'
  static_configs:
    - targets: ['localhost:9090']
  metrics_path: /metrics
  scrape_interval: 5s
  scrape_timeout: 3s
  relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__metrics_path__]
      target_label: metrics_path
    - source_labels: [__name__]
      regex: request_rate_
      target_label: throughput_metric
EOF
    
    echo "Métricas de performance configuradas com sucesso!"
}

# Função para configurar capacidade
setup_performance_capacity() {
    echo "Configurando capacidade..."
    
    # Cria configuração de capacidade
    cat << EOF > prometheus/capacity.yml
# Configuração de capacidade
targets:
  - name: CPU
    threshold: 80
    alert: "HighCPUUsage"
    message: "CPU usage is above 80%"

  - name: Memory
    threshold: 90
    alert: "HighMemoryUsage"
    message: "Memory usage is above 90%"

  - name: Disk
    threshold: 95
    alert: "HighDiskUsage"
    message: "Disk usage is above 95%"

# Configuração de escalabilidade
autoscaling:
  enabled: true
  min_replicas: 2
  max_replicas: 10
  target_cpu_usage: 70
  target_memory_usage: 80

# Configuração de cache
storage:
  cache_size: 1GB
  cache_ttl: 1h
EOF
    
    echo "Capacidade configurada com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_performance_tuning
            setup_performance_metrics
            setup_performance_capacity
            exit 0
            ;;
        -t|--tuning)
            setup_performance_tuning
            exit 0
            ;;
        -m|--metrics)
            setup_performance_metrics
            exit 0
            ;;
        -c|--capacity)
            setup_performance_capacity
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
