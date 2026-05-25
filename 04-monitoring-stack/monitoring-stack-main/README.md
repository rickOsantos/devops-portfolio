# Monitoramento de Aplicativos em Tempo Real

Este projeto implementa uma solução completa de monitoramento para aplicações usando Prometheus, Grafana e a pilha ELK (Elasticsearch, Logstash, Kibana). A solução permite monitorar métricas, logs e desempenho em tempo real.

## Arquitetura

```
monitoring-app/
├── prometheus/
│   ├── prometheus.yml
│   └── alerts.yml
├── grafana/
│   ├── dashboards/
│   │   ├── app-performance.json
│   │   ├── logs-analysis.json
│   │   └── system-health.json
│   └── datasources/
│       └── prometheus.yml
├── elk/
│   ├── elasticsearch/
│   │   └── config.yml
│   ├── logstash/
│   │   └── pipeline.conf
│   └── kibana/
│       └── config.yml
└── scripts/
    ├── deploy-stack.sh
    ├── configure-grafana.sh
    ├── configure-elk.sh
    └── validate-monitoring.sh
```

## Pré-requisitos

- Docker e Docker Compose
- Kubernetes (opcional)
- Aplicação para monitorar
- Acesso à internet para download de imagens

## Instalação

### 1. Usando Docker Compose

```bash
# Iniciar todos os serviços
docker-compose up -d

# Verificar status dos containers
docker-compose ps

# Acessar os serviços
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- Kibana: http://localhost:5601
- Elasticsearch: http://localhost:9200
```

### 2. Usando Kubernetes

```bash
# Aplicar configurações
kubectl apply -f k8s/

# Verificar pods
kubectl get pods

# Acessar os serviços
- Prometheus: kubectl port-forward svc/prometheus 9090:9090
- Grafana: kubectl port-forward svc/grafana 3000:3000
- Kibana: kubectl port-forward svc/kibana 5601:5601
```

## Funcionalidades

### Prometheus

- Coleta de métricas
- Alertas configuráveis
- Scraping automático
- Regras de alerta
- Jobs configuráveis

### Grafana

- Dashboards pré-configurados
- Visualizações em tempo real
- Alertas integrados
- Templates dinâmicos
- Datasources configuráveis

### ELK Stack

- Logstash: Processamento de logs
- Elasticsearch: Armazenamento e indexação
- Kibana: Visualização e análise
- Pipeline de logs
- Indexação automatizada

## Configuração

### Prometheus

```yaml
# prometheus/prometheus.yml
scrape_configs:
  - job_name: 'app-metrics'
    static_configs:
      - targets: ['app-service:8080']

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
```

### Grafana

```yaml
# grafana/datasources/prometheus.yml
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    access: proxy
```

### ELK

```yaml
# elk/logstash/pipeline.conf
input {
  file {
    path => "/var/log/app/*.log"
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

## Dashboards

- **App Performance**: Métricas de desempenho da aplicação
- **Logs Analysis**: Análise de logs em tempo real
- **System Health**: Monitoramento do sistema
- **Network Traffic**: Tráfego de rede
- **Resource Usage**: Uso de recursos

## Alertas

- Uso de CPU acima de 80%
- Memória acima de 90%
- Logs de erro
- Latência alta
- Falhas de serviço

## Segurança

- Autenticação básica
- TLS/SSL
- RBAC
- Redes isoladas
- Logs de auditoria

## Contribuição

1. Faça um fork do repositório
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
