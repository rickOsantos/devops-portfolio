#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Realiza manutenção completa"
    echo "  -u, --update       Atualiza componentes"
    echo "  -b, --backup       Faz backup dos dados"
    echo "  -r, --restore      Restaura dados"
    echo "  -c, --cleanup      Limpa recursos não utilizados"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para atualizar componentes
update_components() {
    echo "Atualizando componentes..."
    
    # Atualiza Docker images
    docker-compose pull
    
    # Atualiza dashboards do Grafana
    docker exec grafana grafana-cli plugins update-all
    
    # Atualiza plugins do Kibana
    docker exec kibana bin/kibana-plugin list | grep -v "No plugins installed"
    
    echo "Componentes atualizados com sucesso!"
}

# Função para fazer backup
backup_data() {
    echo "Fazendo backup dos dados..."
    
    # Cria diretório para backup
    backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $backup_dir
    
    # Backup do Elasticsearch
    curl -X PUT "http://localhost:9200/_snapshot/backup" -H 'Content-Type: application/json' -d'
    {
      "type": "fs",
      "settings": {
        "location": "'$backup_dir'/elasticsearch"
      }
    }'
    
    # Backup do Prometheus
    docker exec prometheus promtool tsdb create-blocks-from openmetrics --output-directory $backup_dir/prometheus
    
    # Backup dos dashboards do Grafana
    docker exec grafana grafana-cli admin settings export > $backup_dir/grafana-settings.json
    
    echo "Backup realizado com sucesso em $backup_dir!"
}

# Função para restaurar dados
restore_data() {
    echo "Restaurando dados..."
    
    # Verifica se há backup disponível
    latest_backup=$(ls -t backup/ | head -n 1)
    if [ -z "$latest_backup" ]; then
        echo "Nenhum backup encontrado."
        exit 1
    fi
    
    # Restaura Elasticsearch
    curl -X POST "http://localhost:9200/_snapshot/backup/_restore"
    
    # Restaura Prometheus
    docker exec prometheus promtool tsdb restore $latest_backup/prometheus
    
    # Restaura dashboards do Grafana
    docker exec grafana grafana-cli admin settings import < $latest_backup/grafana-settings.json
    
    echo "Dados restaurados com sucesso!"
}

# Função para limpar recursos
cleanup_resources() {
    echo "Limpando recursos..."
    
    # Remove containers parados
    docker rm -f $(docker ps -a -q)
    
    # Remove volumes não utilizados
    docker volume prune -f
    
    # Remove imagens não utilizadas
    docker image prune -f
    
    # Limpa cache do Docker
    docker system prune -f
    
    echo "Recursos limpos com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            update_components
            backup_data
            cleanup_resources
            exit 0
            ;;
        -u|--update)
            update_components
            exit 0
            ;;
        -b|--backup)
            backup_data
            exit 0
            ;;
        -r|--restore)
            restore_data
            exit 0
            ;;
        -c|--cleanup)
            cleanup_resources
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
