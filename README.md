# 🚀 Kubernetes Manifests - Ojuara 🦄

Este repositório é a **Fonte Única da Verdade** para o nosso cluster Kubernetes na OCI. Utilizamos a metodologia **GitOps** com ArgoCD para garantir que o estado do cluster sempre reflita o código presente no GitHub.

## 🌟 Estado Atual do Cluster

O cluster foi recentemente limpo e otimizado, contando com:

- **Infraestrutura Core:**
  - **ArgoCD:** Gerenciamento de GitOps e deploy contínuo.
  - **Cert-Manager:** Emissão automática de certificados TLS via Let's Encrypt.
  - **NGINX Ingress Controller:** Ponto de entrada único para tráfego HTTP/HTTPS.
- **Aplicações Ativas:**
  - **Finances:** Gerenciador financeiro (`finances.app.ojuara.tech`).
  - **Impostor Game:** Aplicação interativa de jogo.

---

## ➕ Como Subir uma Nova Aplicação (Passo a Passo)

Para adicionar uma nova app ao cluster, siga este fluxo GitOps:

### 1. Criar a pasta da Aplicação
Crie uma pasta em `applications/<nome-da-sua-app>/`.

### 2. Adicionar os Manifestos Kubernetes
Dentro da pasta criada, você precisa de pelo menos 3 arquivos:

- **`deployment.yaml`**: Define como o container vai rodar (imagem, portas, recursos).
- **`service.yaml`**: Cria um IP interno para a app ser achada dentro do cluster.
- **`ingress.yaml`**: Define a URL externa (ex: `minha-app.app.ojuara.tech`) e vincula ao Ingress Controller e ao TLS.

#### Exemplo de estrutura (baseado no Finances):
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-app
  namespace: minha-app
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: minha-app
        image: usuario/imagem:tag
        ports:
        - containerPort: 3000
```

### 3. Criar o Bootstrap no ArgoCD
Para que o ArgoCD "enxergue" sua nova pasta, crie um arquivo em `argocd-bootstrap/<nome-da-app>-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: minha-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/tiquinhonew/kubernetes-manifests.git
    targetRevision: HEAD
    path: applications/minha-app # Caminho da pasta que você criou no passo 1
  destination:
    server: https://kubernetes.default.svc
    namespace: minha-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true # Cria o namespace automaticamente se não existir
```

### 4. Sincronizar (Git Push)
Adicione os arquivos e envie para o GitHub:
```bash
git add .
git commit -m "feat: Adicionando nova aplicação <nome>"
git push origin main
```

---

## 🛠️ Manutenção e Troubleshooting Comum

- **DNS Quebrado:** Se os pods não resolverem nomes, verifique se o firewall do nó (`iptables -F`) ou o `Source/Destination Check` na console da OCI estão corretos.
- **ArgoCD OutOfSync:** Se o Ingress estiver OutOfSync, verifique se são os Jobs de admissão (geralmente ignorados via `ignoreDifferences`).
- **Logs:** Use `kubectl logs -l app=<nome-da-app> -n <namespace>` para ver o que está acontecendo em tempo real.

---
**"O Git é a sua infraestrutura. O cluster é apenas um reflexo."**
