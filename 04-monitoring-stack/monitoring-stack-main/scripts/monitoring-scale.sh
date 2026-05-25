#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todo o escalonamento"
    echo "  -p, --prometheus   Configura escalonamento do Prometheus"
    echo "  -g, --grafana      Configura escalonamento do Grafana"
    echo "  -e, --elk          Configura escalonamento do ELK"
    echo "  -c, --cpu          Configura baseado em CPU"
    echo "  -m, --memory       Configura baseado em memória"
    echo "  -r, --requests     Configura baseado em requisições"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar escalonamento do Prometheus
setup_prometheus_scale() {
    echo "Configurando escalonamento do Prometheus..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/prometheus-scaling.yml
# Configuração de escalonamento do Prometheus
replicas:
  min: 2
  max: 10

metrics:
  - name: cpu
    threshold: 80
    weight: 0.5
  - name: memory
    threshold: 90
    weight: 0.3
  - name: requests
    threshold: 1000
    weight: 0.2

policies:
  - name: high_load
    conditions:
      - cpu > 80
      - memory > 90
      - requests > 1000
    actions:
      - scale_up
      - notify_alert

  - name: low_load
    conditions:
      - cpu < 30
      - memory < 40
      - requests < 500
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento do Prometheus configurado com sucesso!"
}

# Função para configurar escalonamento do Grafana
setup_grafana_scale() {
    echo "Configurando escalonamento do Grafana..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/grafana-scaling.yml
# Configuração de escalonamento do Grafana
replicas:
  min: 2
  max: 5

metrics:
  - name: cpu
    threshold: 70
    weight: 0.4
  - name: memory
    threshold: 80
    weight: 0.3
  - name: requests
    threshold: 500
    weight: 0.3

policies:
  - name: high_load
    conditions:
      - cpu > 70
      - memory > 80
      - requests > 500
    actions:
      - scale_up
      - notify_alert

  - name: low_load
    conditions:
      - cpu < 20
      - memory < 30
      - requests < 100
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento do Grafana configurado com sucesso!"
}

# Função para configurar escalonamento do ELK
setup_elk_scale() {
    echo "Configurando escalonamento do ELK..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/elk-scaling.yml
# Configuração de escalonamento do ELK
replicas:
  min: 3
  max: 10

metrics:
  - name: cpu
    threshold: 85
    weight: 0.4
  - name: memory
    threshold: 95
    weight: 0.3
  - name: disk
    threshold: 90
    weight: 0.3

policies:
  - name: high_load
    conditions:
      - cpu > 85
      - memory > 95
      - disk > 90
    actions:
      - scale_up
      - notify_alert

  - name: low_load
    conditions:
      - cpu < 30
      - memory < 40
      - disk < 60
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento do ELK configurado com sucesso!"
}

# Função para configurar escalonamento baseado em CPU
setup_cpu_scale() {
    echo "Configurando escalonamento baseado em CPU..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/cpu-scaling.yml
# Configuração de escalonamento baseado em CPU
thresholds:
  - name: low
    value: 30
    action: scale_down
  - name: medium
    value: 70
    action: maintain
  - name: high
    value: 90
    action: scale_up

weights:
  prometheus: 0.5
  grafana: 0.3
  elk: 0.2

policies:
  - name: cpu_high
    conditions:
      - cpu > 90
    actions:
      - scale_up
      - notify_alert

  - name: cpu_low
    conditions:
      - cpu < 30
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento baseado em CPU configurado com sucesso!"
}

# Função para configurar escalonamento baseado em memória
setup_memory_scale() {
    echo "Configurando escalonamento baseado em memória..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/memory-scaling.yml
# Configuração de escalonamento baseado em memória
thresholds:
  - name: low
    value: 40
    action: scale_down
  - name: medium
    value: 80
    action: maintain
  - name: high
    value: 95
    action: scale_up

weights:
  prometheus: 0.4
  grafana: 0.3
  elk: 0.3

policies:
  - name: memory_high
    conditions:
      - memory > 95
    actions:
      - scale_up
      - notify_alert

  - name: memory_low
    conditions:
      - memory < 40
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento baseado em memória configurado com sucesso!"
}

# Função para configurar escalonamento baseado em requisições
setup_requests_scale() {
    echo "Configurando escalonamento baseado em requisições..."
    
    # Cria configuração de escalonamento
    cat << EOF > scaling/requests-scaling.yml
# Configuração de escalonamento baseado em requisições
thresholds:
  - name: low
    value: 100
    action: scale_down
  - name: medium
    value: 500
    action: maintain
  - name: high
    value: 1000
    action: scale_up

weights:
  prometheus: 0.3
  grafana: 0.4
  elk: 0.3

policies:
  - name: requests_high
    conditions:
      - requests > 1000
    actions:
      - scale_up
      - notify_alert

  - name: requests_low
    conditions:
      - requests < 100
    actions:
      - scale_down
      - notify_alert
EOF
    
    echo "Escalonamento baseado em requisições configurado com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_prometheus_scale
            setup_grafana_scale
            setup_elk_scale
            setup_cpu_scale
            setup_memory_scale
            setup_requests_scale
            exit 0
            ;;
        -p|--prometheus)
            setup_prometheus_scale
            exit 0
            ;;
        -g|--grafana)
            setup_grafana_scale
            exit 0
            ;;
        -e|--elk)
            setup_elk_scale
            exit 0
            ;;
        -c|--cpu)
            setup_cpu_scale
            exit 0
            ;;
        -m|--memory)
            setup_memory_scale
            exit 0
            ;;
        -r|--requests)
            setup_requests_scale
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
