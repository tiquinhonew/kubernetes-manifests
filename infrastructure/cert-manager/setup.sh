#!/bin/bash

set -e

echo "🚀 Configurando cert-manager do zero..."

# Variáveis - CUSTOMIZE AQUI
EMAIL="douglas@purplebit.com.br"
INGRESS_CLASS="nginx"
CERT_MANAGER_VERSION="v1.13.2"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_green() { echo -e "${GREEN}$1${NC}"; }
echo_yellow() { echo -e "${YELLOW}$1${NC}"; }
echo_red() { echo -e "${RED}$1${NC}"; }

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    echo_red "❌ kubectl não encontrado. Instale kubectl primeiro."
    exit 1
fi

# Verificar conectividade com cluster
echo_yellow "🔍 Verificando conectividade com o cluster..."
if ! kubectl cluster-info &> /dev/null; then
    echo_red "❌ Não foi possível conectar ao cluster k8s"
    exit 1
fi
echo_green "✅ Cluster k8s acessível"

# Instalar CRDs do cert-manager
echo_yellow "📦 Instalando CRDs do cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml

# Instalar cert-manager
echo_yellow "🔧 Instalando cert-manager $CERT_MANAGER_VERSION..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.yaml

# Aguardar cert-manager estar pronto
echo_yellow "⏳ Aguardando cert-manager estar pronto..."
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-webhook -n cert-manager

echo_green "✅ cert-manager instalado com sucesso!"

# Criar arquivo de configuração personalizado
cat > cert-manager-issuers.yaml <<EOF
# ClusterIssuer para Let's Encrypt Staging
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: $INGRESS_CLASS
      selector: {}

---
# ClusterIssuer para Let's Encrypt Production
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: $INGRESS_CLASS
      selector: {}

---
# Self-signed issuer
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

# Aplicar configurações
echo_yellow "⚙️ Aplicando configurações dos ClusterIssuers..."
kubectl apply -f cert-manager-issuers.yaml

# Aguardar issuers estarem prontos
echo_yellow "⏳ Aguardando ClusterIssuers estarem prontos..."
sleep 10

# Verificar status dos issuers
echo_yellow "🔍 Verificando status dos ClusterIssuers..."
kubectl get clusterissuers

echo_green "✅ Configuração concluída!"

# Exemplo de uso
cat > example-certificate.yaml <<EOF
# Exemplo de certificado usando Let's Encrypt staging
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: default
spec:
  secretName: example-tls-secret
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
  dnsNames:
  - exemplo.com.br
  - www.exemplo.com.br
EOF

cat > example-ingress.yaml <<EOF
# Exemplo de Ingress com certificado automático
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: $INGRESS_CLASS
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  tls:
  - hosts:
    - exemplo.com.br
    - www.exemplo.com.br
    secretName: example-tls-secret
  rules:
  - host: exemplo.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
EOF

echo_yellow "📝 Arquivos de exemplo criados:"
echo "  - cert-manager-issuers.yaml"
echo "  - example-certificate.yaml"
echo "  - example-ingress.yaml"

echo ""
echo_green "🎉 Setup do cert-manager concluído!"
echo ""
echo_yellow "📋 Próximos passos:"
echo "1. Edite o email nos ClusterIssuers se necessário"
echo "2. Teste com letsencrypt-staging primeiro"
echo "3. Depois mude para letsencrypt-prod"
echo "4. Para usar, adicione a annotation no seu Ingress:"
echo "   cert-manager.io/cluster-issuer: letsencrypt-staging"
echo ""
echo_yellow "🔍 Comandos úteis:"
echo "  kubectl get clusterissuers"
echo "  kubectl get certificates --all-namespaces"
echo "  kubectl describe certificate nome-do-certificado"
echo "  kubectl logs -n cert-manager deployment/cert-manager"