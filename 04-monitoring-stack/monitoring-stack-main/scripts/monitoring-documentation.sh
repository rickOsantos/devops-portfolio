#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Gera toda a documentação"
    echo "  -i, --installation Gera documentação de instalação"
    echo "  -c, --configuration Gera documentação de configuração"
    echo "  -u, --usage        Gera documentação de uso"
    echo "  -m, --maintenance  Gera documentação de manutenção"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para gerar documentação de instalação
generate_installation_docs() {
    echo "Gerando documentação de instalação..."
    
    # Cria diretório para documentação
    mkdir -p docs/installation
    
    # Gera documentação
    cat << EOF > docs/installation/installation.md
# Instalação do Stack de Monitoramento

## Pré-requisitos
- Docker e Docker Compose
- Portas disponíveis:
  - Prometheus: 9090
  - Grafana: 3000
  - Elasticsearch: 9200
  - Kibana: 5601
  - Logstash: 5044

## Instalação
1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/monitoring-app.git
```

2. Navegue para o diretório:
```bash
cd monitoring-app
```

3. Inicie os serviços:
```bash
docker-compose up -d
```

## Verificação
Verifique se os serviços estão rodando:
```bash
./scripts/monitoring-status.sh -a
```

## Acesso
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
- Kibana: http://localhost:5601
EOF
    
    echo "Documentação de instalação gerada com sucesso!"
}

# Função para gerar documentação de configuração
generate_configuration_docs() {
    echo "Gerando documentação de configuração..."
    
    # Gera documentação
    cat << EOF > docs/configuration/configuration.md
# Configuração do Stack de Monitoramento

## Prometheus
```yaml
# Configuração básica
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

# Configuração de alertas
alert_groups:
  - name: app-alerts
    rules:
      - alert: HighCPUUsage
        expr: rate(process_cpu_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: critical
```

## Grafana
```ini
[server]
http_port = 3000
protocol = http

[security]
admin_user = admin
admin_password = admin

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db
```

## ELK
```yaml
# Elasticsearch
cluster.name: "elasticsearch"
node.name: "elk-node"

# Kibana
server.port: 5601
server.host: "0.0.0.0"
```

## Integrações
```yaml
# Slack
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
channel: "#alerts"

# Email
smtp:
  host: smtp.example.com
  port: 587
  user: admin@example.com
```
EOF
    
    echo "Documentação de configuração gerada com sucesso!"
}

# Função para gerar documentação de uso
generate_usage_docs() {
    echo "Gerando documentação de uso..."
    
    # Gera documentação
    cat << EOF > docs/usage/usage.md
# Uso do Stack de Monitoramento

## Dashboards
- CPU Usage
- Memory Usage
- Request Rate
- Error Rate
- Latency
- User Distribution

## Alertas
- High CPU Usage
- High Memory Usage
- High Request Rate
- High Error Rate
- High Latency

## Logs
- Error Logs
- Access Logs
- Application Logs
- System Logs

## Métricas
- CPU Metrics
- Memory Metrics
- Network Metrics
- Application Metrics
- Custom Metrics

## Comandos Úteis
```bash
# Status
./scripts/monitoring-status.sh -a

# Dashboard
./scripts/monitoring-dashboard.sh -a

# Logs
./scripts/monitoring-logs.sh -a

# Métricas
./scripts/monitoring-metrics.sh -a
```
EOF
    
    echo "Documentação de uso gerada com sucesso!"
}

# Função para gerar documentação de manutenção
generate_maintenance_docs() {
    echo "Gerando documentação de manutenção..."
    
    # Gera documentação
    cat << EOF > docs/maintenance/maintenance.md
# Manutenção do Stack de Monitoramento

## Backup
```bash
# Realizar backup completo
./scripts/monitoring-backup.sh -a

# Restaurar backup
./scripts/monitoring-backup.sh -r
```

## Segurança
```bash
# Configurar segurança
./scripts/monitoring-security.sh -a

# Gerenciar certificados
./scripts/monitoring-security.sh -c
```

## Performance
```bash
# Otimizar performance
./scripts/monitoring-performance.sh -a

# Verificar métricas
./scripts/monitoring-performance.sh -m
```

## Troubleshooting
```bash
# Verificar problemas
./scripts/monitoring-troubleshooting.sh -a

# Verificar logs
./scripts/monitoring-troubleshooting.sh -l
```

## Atualização
```bash
# Atualizar componentes
./scripts/monitoring-maintenance.sh -u

# Limpar recursos
./scripts/monitoring-maintenance.sh -c
```
EOF
    
    echo "Documentação de manutenção gerada com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            generate_installation_docs
            generate_configuration_docs
            generate_usage_docs
            generate_maintenance_docs
            exit 0
            ;;
        -i|--installation)
            generate_installation_docs
            exit 0
            ;;
        -c|--configuration)
            generate_configuration_docs
            exit 0
            ;;
        -u|--usage)
            generate_usage_docs
            exit 0
            ;;
        -m|--maintenance)
            generate_maintenance_docs
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
