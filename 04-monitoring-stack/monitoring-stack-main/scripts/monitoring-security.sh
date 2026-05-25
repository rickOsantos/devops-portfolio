#!/bin/bash

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [opção]"
    echo "Opções:"
    echo "  -a, --all          Configura toda a segurança"
    echo "  -p, --prometheus   Configura segurança do Prometheus"
    echo "  -g, --grafana      Configura segurança do Grafana"
    echo "  -e, --elk          Configura segurança do ELK"
    echo "  -c, --certs        Configura certificados"
    echo "  -h, --help         Mostra esta ajuda"
    exit 1
}

# Função para configurar segurança do Prometheus
setup_prometheus_security() {
    echo "Configurando segurança do Prometheus..."
    
    # Cria configuração de segurança
    cat << EOF > prometheus/security.yml
# Configuração de autenticação
basic_auth_users:
  admin: \$2y\$10\$hash
  user: \$2y\$10\$hash

# Configuração de TLS
server:
  tls_config:
    cert_file: /etc/prometheus/tls.crt
    key_file: /etc/prometheus/tls.key

# Configuração de RBAC
authorization:
  enabled: true
  rules:
    - role: admin
      users:
        - admin
      permissions:
        - "*"
    - role: user
      users:
        - user
      permissions:
        - "read:targets"
        - "read:rules"
        - "read:alerts"
EOF
    
    echo "Segurança do Prometheus configurada com sucesso!"
}

# Função para configurar segurança do Grafana
setup_grafana_security() {
    echo "Configurando segurança do Grafana..."
    
    # Cria configuração de segurança
    cat << EOF > grafana/security.ini
[security]
# Autenticação
admin_user = admin
admin_password = \$2a\$10\$hash

# TLS
protocol = https
http_addr = 0.0.0.0
http_port = 3000

# Certificados
cert_file = /etc/grafana/tls.crt
key_file = /etc/grafana/tls.key

# RBAC
disable_gravatar = true
allow_embedding = false

# API Keys
api_key_max_seconds_to_live = 86400
api_key_max_seconds_to_live_per_role = admin:86400,user:86400
EOF
    
    echo "Segurança do Grafana configurada com sucesso!"
}

# Função para configurar segurança do ELK
setup_elk_security() {
    echo "Configurando segurança do ELK..."
    
    # Cria configuração de segurança
    cat << EOF > elk/security.yml
# Configuração de autenticação
xpack.security.enabled: true
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: /etc/elasticsearch/tls/keystore.jks
xpack.security.http.ssl.truststore.path: /etc/elasticsearch/tls/truststore.jks

# Usuários
xpack.security.users:
  kibana_system:
    password: \$2y\$10\$hash
    roles: ["kibana_system"]
  elastic:
    password: \$2y\$10\$hash
    roles: ["superuser"]

# RBAC
xpack.security.authc.realms:
  native:
    order: 0

# Configuração do Kibana
xpack.security.kibana:
  enabled: true
  ssl:
    enabled: true
    keystore.path: /etc/kibana/tls/keystore.jks
    truststore.path: /etc/kibana/tls/truststore.jks
EOF
    
    echo "Segurança do ELK configurada com sucesso!"
}

# Função para configurar certificados
setup_certificates() {
    echo "Configurando certificados..."
    
    # Cria diretório para certificados
    mkdir -p certs
    
    # Gera certificados auto-assinados
    openssl req -x509 -newkey rsa:4096 -keyout certs/tls.key -out certs/tls.crt -days 365 \
      -subj "/CN=localhost" -nodes
    
    # Gera keystore para ELK
    keytool -genkeypair -alias elk -keyalg RSA -keysize 2048 -validity 365 \
      -keystore certs/elk.jks -storepass changeit -keypass changeit \
      -dname "CN=localhost,OU=ELK,O=Elastic,L=Paris,S=Ile-de-France,C=FR"
    
    echo "Certificados configurados com sucesso!"
}

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            setup_prometheus_security
            setup_grafana_security
            setup_elk_security
            setup_certificates
            exit 0
            ;;
        -p|--prometheus)
            setup_prometheus_security
            exit 0
            ;;
        -g|--grafana)
            setup_grafana_security
            exit 0
            ;;
        -e|--elk)
            setup_elk_security
            exit 0
            ;;
        -c|--certs)
            setup_certificates
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
