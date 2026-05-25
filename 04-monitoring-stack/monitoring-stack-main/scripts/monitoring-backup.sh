#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Realiza backup completo"
    echo "  -p, --prometheus   Realiza backup do Prometheus"
    echo "  -g, --grafana      Realiza backup do Grafana"
    echo "  -e, --elk          Realiza backup do ELK"
    echo "  -r, --restore      Restaura backup"
    echo "  -c, --cleanup      Limpa backups antigos"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para realizar backup do Prometheus
backup_prometheus() {
    echo "Realizando backup do Prometheus..."
    
    # Cria diretório para backup
    backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $backup_dir/prometheus
    
    # Backup dos dados
    docker exec prometheus promtool tsdb create-blocks-from openmetrics --output-directory $backup_dir/prometheus
    
    # Backup das configurações
    docker cp prometheus:/etc/prometheus/prometheus.yml $backup_dir/prometheus/
    docker cp prometheus:/etc/prometheus/rules/ $backup_dir/prometheus/rules/
    
    echo "Backup do Prometheus realizado com sucesso em $backup_dir/prometheus!"
}

# Função para realizar backup do Grafana
backup_grafana() {
    echo "Realizando backup do Grafana..."
    
    # Cria diretório para backup
    backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $backup_dir/grafana
    
    # Backup das configurações
    docker cp grafana:/etc/grafana/grafana.ini $backup_dir/grafana/
    docker cp grafana:/var/lib/grafana/dashboards/ $backup_dir/grafana/dashboards/
    docker cp grafana:/var/lib/grafana/plugins/ $backup_dir/grafana/plugins/
    
    # Backup dos dados
    docker exec grafana grafana-cli admin settings export > $backup_dir/grafana/settings.json
    
    echo "Backup do Grafana realizado com sucesso em $backup_dir/grafana!"
}

# Função para realizar backup do ELK
backup_elk() {
    echo "Realizando backup do ELK..."
    
    # Cria diretório para backup
    backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $backup_dir/elk
    
    # Backup do Elasticsearch
    curl -X PUT "http://localhost:9200/_snapshot/backup" -H 'Content-Type: application/json' -d'
    {
      "type": "fs",
      "settings": {
        "location": "'$backup_dir'/elk/elasticsearch"
      }
    }'
    
    # Backup do Kibana
    docker exec kibana bin/kibana-plugin list > $backup_dir/elk/kibana-plugins.txt
    
    echo "Backup do ELK realizado com sucesso em $backup_dir/elk!"
}

# Função para restaurar backup
restore_backup() {
    echo "Restaurando backup..."
    
    # Verifica se há backup disponível
    latest_backup=$(ls -t backup/ | head -n 1)
    if [ -z "$latest_backup" ]; then
        echo "Nenhum backup encontrado."
        exit 1
    fi
    
    # Restaura Prometheus
    docker exec prometheus promtool tsdb restore backup/$latest_backup/prometheus
    
    # Restaura Grafana
    docker exec grafana grafana-cli admin settings import < backup/$latest_backup/grafana/settings.json
    
    # Restaura ELK
    curl -X POST "http://localhost:9200/_snapshot/backup/_restore"
    
    echo "Backup restaurado com sucesso!"
}

# Função para limpar backups antigos
cleanup_backups() {
    echo "Limpando backups antigos..."
    
    # Mantém apenas os últimos 7 dias de backups
    find backup/ -type d -mtime +7 -exec rm -rf {} +
    
    echo "Backups antigos limpos com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            backup_prometheus
            backup_grafana
            backup_elk
            exit 0
            ;;
        -p|--prometheus)
            backup_prometheus
            exit 0
            ;;
        -g|--grafana)
            backup_grafana
            exit 0
            ;;
        -e|--elk)
            backup_elk
            exit 0
            ;;
        -r|--restore)
            restore_backup
            exit 0
            ;;
        -c|--cleanup)
            cleanup_backups
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
