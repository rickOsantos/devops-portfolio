#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todo o sistema de logs"
    echo "  -c, --collect      Configura coleta de logs"
    echo "  -p, --process      Configura processamento de logs"
    echo "  -s, --search       Configura busca de logs"
    echo "  -a, --analyze      Configura análise de logs"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar coleta de logs
setup_log_collection() {
    echo "Configurando coleta de logs..."
    
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

  beats {
    port => 5044
  }
}
EOF
    
    echo "Coleta de logs configurada com sucesso!"
}

# Função para configurar processamento de logs
setup_log_processing() {
    echo "Configurando processamento de logs..."
    
    # Cria configuração de processamento
    cat << EOF > elk/logstash/filter.conf
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

  if [log_level] == "ERROR" {
    mutate {
      add_tag => [ "error" ]
    }
  }

  if [log_level] == "WARN" {
    mutate {
      add_tag => [ "warning" ]
    }
  }
}
EOF
    
    echo "Processamento de logs configurado com sucesso!"
}

# Função para configurar busca de logs
setup_log_search() {
    echo "Configurando busca de logs..."
    
    # Cria configuração de indexação
    cat << EOF > elk/elasticsearch/index-pattern.json
{
  "index_patterns": ["app-logs-*"],
  "time_field": "@timestamp",
  "fields": [
    {
      "name": "timestamp",
      "type": "date"
    },
    {
      "name": "log_level",
      "type": "keyword"
    },
    {
      "name": "service",
      "type": "keyword"
    },
    {
      "name": "log_message",
      "type": "text"
    }
  ]
}
EOF
    
    echo "Busca de logs configurada com sucesso!"
}

# Função para configurar análise de logs
setup_log_analysis() {
    echo "Configurando análise de logs..."
    
    # Cria configuração de análise
    cat << EOF > elk/kibana/analysis.json
{
  "visualizations": [
    {
      "title": "Error Rate",
      "type": "timeseries",
      "index": "app-logs-*",
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
      },
      "aggs": [
        {
          "date_histogram": {
            "field": "@timestamp",
            "interval": "minute"
          }
        }
      ]
    },
    {
      "title": "Error Distribution",
      "type": "pie",
      "index": "app-logs-*",
      "aggs": [
        {
          "terms": {
            "field": "service"
          }
        }
      ]
    },
    {
      "title": "Log Analysis Dashboard",
      "type": "dashboard",
      "panels": [
        {
          "title": "Error Rate",
          "type": "timeseries",
          "datasource": "app-logs-*"
        },
        {
          "title": "Error Distribution",
          "type": "pie",
          "datasource": "app-logs-*"
        }
      ]
    }
  ]
}
EOF
    
    echo "Análise de logs configurada com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_log_collection
            setup_log_processing
            setup_log_search
            setup_log_analysis
            exit 0
            ;;
        -c|--collect)
            setup_log_collection
            exit 0
            ;;
        -p|--process)
            setup_log_processing
            exit 0
            ;;
        -s|--search)
            setup_log_search
            exit 0
            ;;
        -a|--analyze)
            setup_log_analysis
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
