#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura todas as visualizações"
    echo "  -g, --grafana      Configura visualizações do Grafana"
    echo "  -k, --kibana       Configura visualizações do Kibana"
    echo "  -c, --charts       Configura gráficos e dashboards"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar visualizações do Grafana
setup_grafana_visualizations() {
    echo "Configurando visualizações do Grafana..."
    
    # Cria diretórios para visualizações
    mkdir -p grafana/visualizations
    
    # Cria configuração de painéis
    cat << EOF > grafana/visualizations/panels.json
{
  "panels": [
    {
      "title": "CPU Usage",
      "type": "timeseries",
      "datasource": "Prometheus",
      "query": "rate(process_cpu_seconds_total[5m])",
      "thresholds": [
        {
          "color": "green",
          "value": null
        },
        {
          "color": "yellow",
          "value": 0.8
        },
        {
          "color": "red",
          "value": 0.9
        }
      ]
    },
    {
      "title": "Memory Usage",
      "type": "timeseries",
      "datasource": "Prometheus",
      "query": "process_resident_memory_bytes",
      "thresholds": [
        {
          "color": "green",
          "value": null
        },
        {
          "color": "yellow",
          "value": 1000000000
        },
        {
          "color": "red",
          "value": 2000000000
        }
      ]
    },
    {
      "title": "Request Rate",
      "type": "timeseries",
      "datasource": "Prometheus",
      "query": "rate(http_requests_total[5m])",
      "thresholds": [
        {
          "color": "green",
          "value": null
        },
        {
          "color": "yellow",
          "value": 1000
        },
        {
          "color": "red",
          "value": 5000
        }
      ]
    }
  ]
}
EOF
    
    echo "Visualizações do Grafana configuradas com sucesso!"
}

# Função para configurar visualizações do Kibana
setup_kibana_visualizations() {
    echo "Configurando visualizações do Kibana..."
    
    # Cria configuração de visualizações
    cat << EOF > kibana/visualizations/config.json
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
      "title": "Request Duration",
      "type": "timeseries",
      "index": "app-logs-*",
      "query": {
        "bool": {
          "must": [
            {
              "exists": {
                "field": "request_duration"
              }
            }
          ]
        }
      },
      "aggs": [
        {
          "avg": {
            "field": "request_duration"
          }
        }
      ]
    },
    {
      "title": "User Distribution",
      "type": "pie",
      "index": "app-logs-*",
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
    
    echo "Visualizações do Kibana configuradas com sucesso!"
}

# Função para configurar gráficos e dashboards
setup_charts() {
    echo "Configurando gráficos e dashboards..."
    
    # Cria configuração de dashboards
    cat << EOF > grafana/dashboards/config.json
{
  "dashboard": {
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
}
EOF
    
    echo "Gráficos e dashboards configurados com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_grafana_visualizations
            setup_kibana_visualizations
            setup_charts
            exit 0
            ;;
        -g|--grafana)
            setup_grafana_visualizations
            exit 0
            ;;
        -k|--kibana)
            setup_kibana_visualizations
            exit 0
            ;;
        -c|--charts)
            setup_charts
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
