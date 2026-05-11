# 🚀 Kubernetes Manifests - PurpleBit 🦄

Este repositório contém todos os manifestos Kubernetes que definem o estado desejado dos nossos serviços e aplicações no cluster. Ele é a **Fonte Única da Verdade** para a nossa infraestrutura e deployments, seguindo os princípios do GitOps.

## 🌟 O que você encontra aqui:

- **`applications/`**: Contém os manifestos Kubernetes para as aplicações de negócio.
  - **`finances/`**: Manifestos para a implantação da nossa API Java (`finances`), incluindo Deployment, Service e Ingress.
- **`infrastructure/`**: Contém os manifestos Kubernetes para os componentes de infraestrutura do cluster.
  - **`argocd/`**: Manifestos para a implantação do ArgoCD, nossa ferramenta de GitOps.
  - **`cert-manager/`**: Configurações para o Cert-Manager, responsável pela emissão e gerenciamento de certificados TLS.
  - **`nginx-ingress-controller/`**: Configurações para o NGINX Ingress Controller, que gerencia o acesso externo aos serviços do cluster.
- **`argocd-bootstrap/`**: Contém as definições de `Application` do ArgoCD que apontam para os manifestos reais nas pastas `applications/` e `infrastructure/`.

## 🛠️ Como funciona (GitOps):

Qualquer alteração no cluster deve ser feita através de um `git push` neste repositório. Ferramentas como o ArgoCD monitoram este repositório e garantem que o estado do cluster esteja sempre sincronizado com o que está definido aqui.

## 🚀 Deployments Atuais:

- **`finances`**: `https://finances.app.purplebit.com.br`
- **`ArgoCD UI`**: `https://argocd.app.purplebit.com.br`

## ➕ Adicionando uma Nova API ao Cluster

Para adicionar uma nova API ao cluster e integrá-la ao fluxo GitOps com ArgoCD, siga os passos abaixo:

1.  **Crie a Estrutura de Pastas:**
    *   Dentro da pasta `applications/`, crie uma nova subpasta com o nome da sua API (ex: `applications/minha-nova-api/`).

2.  **Defina os Manifestos Kubernetes da API:**
    *   Dentro da nova pasta (`applications/minha-nova-api/`), crie os arquivos YAML necessários para sua API:
        *   `deployment.yaml`: Define o Deployment da sua aplicação (imagem Docker, réplicas, portas, etc.).
        *   `service.yaml`: Define o Service para expor sua aplicação dentro do cluster.
        *   `ingress.yaml` (Opcional): Se sua API precisar ser acessível externamente, defina um Ingress.

3.  **Crie a Definição de `Application` do ArgoCD:**
    *   Dentro da pasta `argocd-bootstrap/`, crie um arquivo `minha-nova-api-app.yaml`. Este arquivo dirá ao ArgoCD para monitorar a pasta da sua nova API e implantá-la no cluster.
    *   O app `applications` no Argo CD (definido em `argocd-bootstrap/applications-app.yaml`) irá descobrir e implantar automaticamente esta nova definição de `Application`.
    *   Exemplo de `minha-nova-api-app.yaml`:
        ```yaml
        apiVersion: argoproj.io/v1alpha1
        kind: Application
        metadata:
          name: minha-nova-api
          namespace: argocd
        spec:
          project: default
          source:
            repoURL: https://github.com/tiquinhonew/kubernetes-manifests.git
            targetRevision: HEAD
            path: applications/minha-nova-api # Aponta para a pasta da sua API
          destination:
            server: https://kubernetes.default.svc
            namespace: minha-nova-api # O namespace onde a API será implantada
          syncPolicy:
            automated:
              prune: true
              selfHeal: true
            syncOptions:
              - CreateNamespace=true
        ```

4.  **Adicione e Commite as Alterações:**
    *   Adicione todos os novos arquivos ao Git: `git add applications/minha-nova-api/ argocd-bootstrap/minha-nova-api-app.yaml`
    *   Faça o commit com uma mensagem descritiva: `git commit -m "feat(minha-nova-api): Adiciona nova API ao cluster"`
    *   Envie as alterações para o repositório remoto: `git push`

O ArgoCD detectará as mudanças e começará a implantar sua nova API automaticamente.

---

**"O Git é a sua infraestrutura. O cluster é apenas um reflexo."**