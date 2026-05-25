#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Atualiza todos os componentes"
    echo "  -p, --prometheus   Atualiza Prometheus"
    echo "  -g, --grafana      Atualiza Grafana"
    echo "  -e, --elk          Atualiza ELK"
    echo "  -c, --clean        Limpa cache e imagens antigas"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para atualizar Prometheus
update_prometheus() {
    echo "Atualizando Prometheus..."
    
    # Para o serviço
    docker-compose stop prometheus
    
    # Atualiza imagem
    docker-compose pull prometheus
    
    # Inicia novamente
    docker-compose up -d prometheus
    
    # Verifica status
    if ! docker ps --filter name=prometheus --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Falha ao atualizar Prometheus"
        return
    fi
    
    echo "✅ Prometheus atualizado com sucesso!"
}

# Função para atualizar Grafana
update_grafana() {
    echo "Atualizando Grafana..."
    
    # Para o serviço
    docker-compose stop grafana
    
    # Atualiza imagem
    docker-compose pull grafana
    
    # Inicia novamente
    docker-compose up -d grafana
    
    # Verifica status
    if ! docker ps --filter name=grafana --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Falha ao atualizar Grafana"
        return
    fi
    
    # Atualiza plugins
    docker exec grafana grafana-cli plugins update-all
    
    echo "✅ Grafana atualizado com sucesso!"
}

# Função para atualizar ELK
update_elk() {
    echo "Atualizando ELK..."
    
    # Para os serviços
    docker-compose stop elasticsearch kibana logstash
    
    # Atualiza imagens
    docker-compose pull elasticsearch kibana logstash
    
    # Inicia novamente
    docker-compose up -d elasticsearch kibana logstash
    
    # Verifica status
    if ! docker ps --filter name=elasticsearch --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Falha ao atualizar Elasticsearch"
        return
    fi
    
    if ! docker ps --filter name=kibana --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Falha ao atualizar Kibana"
        return
    fi
    
    if ! docker ps --filter name=logstash --format "{{.Status}}" | grep -q "Up"; then
        echo "❌ Falha ao atualizar Logstash"
        return
    fi
    
    echo "✅ ELK atualizado com sucesso!"
}

# Função para limpar cache e imagens antigas
clean_cache() {
    echo "Limpando cache e imagens antigas..."
    
    # Remove containers parados
    docker rm -f $(docker ps -a -q)
    
    # Remove volumes não utilizados
    docker volume prune -f
    
    # Remove imagens não utilizadas
    docker image prune -f
    
    # Limpa cache do Docker
    docker system prune -f
    
    echo "✅ Cache e imagens antigas limpos com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            update_prometheus
            update_grafana
            update_elk
            clean_cache
            exit 0
            ;;
        -p|--prometheus)
            update_prometheus
            exit 0
            ;;
        -g|--grafana)
            update_grafana
            exit 0
            ;;
        -e|--elk)
            update_elk
            exit 0
            ;;
        -c|--clean)
            clean_cache
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
