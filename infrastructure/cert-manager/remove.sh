#!/bin/bash

echo "🔄 Removendo cert-manager completamente..."

# 1. Remover todos os certificados e recursos do cert-manager
echo "📋 Listando recursos do cert-manager..."
kubectl get certificates --all-namespaces
kubectl get certificaterequests --all-namespaces
kubectl get orders --all-namespaces
kubectl get challenges --all-namespaces
kubectl get clusterissuers
kubectl get issuers --all-namespaces

echo "🗑️ Removendo certificados..."
kubectl delete certificates --all --all-namespaces
kubectl delete certificaterequests --all --all-namespaces
kubectl delete orders --all --all-namespaces
kubectl delete challenges --all --all-namespaces
kubectl delete clusterissuers --all
kubectl delete issuers --all --all-namespaces

# 2. Remover secrets de certificados (cuidado para não remover outros secrets importantes)
echo "🔐 Removendo secrets de certificados TLS..."
kubectl get secrets --all-namespaces -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | "\(.metadata.namespace) \(.metadata.name)"' | while read namespace name; do
    echo "Removendo secret TLS: $namespace/$name"
    kubectl delete secret $name -n $namespace
done

# 3. Remover o deployment do cert-manager
echo "📦 Removendo deployment do cert-manager..."
kubectl delete namespace cert-manager 2>/dev/null || true

# 4. Remover CRDs do cert-manager
echo "🏗️ Removendo CRDs do cert-manager..."
kubectl delete crd certificaterequests.cert-manager.io 2>/dev/null || true
kubectl delete crd certificates.cert-manager.io 2>/dev/null || true
kubectl delete crd challenges.acme.cert-manager.io 2>/dev/null || true
kubectl delete crd clusterissuers.cert-manager.io 2>/dev/null || true
kubectl delete crd issuers.cert-manager.io 2>/dev/null || true
kubectl delete crd orders.acme.cert-manager.io 2>/dev/null || true

# 5. Remover ClusterRoles e ClusterRoleBindings
echo "🔒 Removendo ClusterRoles e bindings..."
kubectl delete clusterrole cert-manager-cainjector 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-certificates 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-challenges 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-clusterissuers 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-ingress-shim 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-issuers 2>/dev/null || true
kubectl delete clusterrole cert-manager-controller-orders 2>/dev/null || true
kubectl delete clusterrole cert-manager-view 2>/dev/null || true
kubectl delete clusterrole cert-manager-edit 2>/dev/null || true

kubectl delete clusterrolebinding cert-manager-cainjector 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-certificates 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-challenges 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-clusterissuers 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-ingress-shim 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-issuers 2>/dev/null || true
kubectl delete clusterrolebinding cert-manager-controller-orders 2>/dev/null || true

# 6. Remover ValidatingWebhookConfiguration
echo "🔌 Removendo webhook configurations..."
kubectl delete validatingwebhookconfiguration cert-manager-webhook 2>/dev/null || true
kubectl delete mutatingwebhookconfiguration cert-manager-webhook 2>/dev/null || true

# 7. Verificar se restou algo
echo "🔍 Verificando recursos restantes..."
kubectl get all -n cert-manager 2>/dev/null || echo "Namespace cert-manager não existe mais"
kubectl api-resources --verbs=list --namespaced -o name | grep cert-manager || echo "Nenhum recurso cert-manager encontrado"

echo "✅ Remoção do cert-manager concluída!"