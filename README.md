# 🚀 Kubernetes Manifests - PurpleBit 🦄

Este repositório contém todos os manifestos Kubernetes que definem o estado desejado dos nossos serviços e aplicações no cluster. Ele é a **Fonte Única da Verdade** para a nossa infraestrutura e deployments, seguindo
os princípios do GitOps.

## 🌟 O que você encontra aqui:

- **`corre-api/`**: Manifestos para a implantação da nossa API Java (`corre-api`), incluindo Deployment, Service e Ingress.
- **`argo-workflows/`**: Configurações e definições para o Argo Workflows, nossa plataforma de orquestração de pipelines de CI.
- **`argo-events/`**: Configurações para o Argo Events, responsável por capturar eventos e disparar nossos workflows.
- **`vault/`**: Manifestos para a implantação do HashiCorp Vault, nosso gerenciador de segredos.
- **`local-path-provisioner/`**: Configuração do provisionador de armazenamento local para o cluster.

## 🛠️ Como funciona (GitOps):

Qualquer alteração no cluster deve ser feita através de um `git push` neste repositório. Ferramentas como o ArgoCD monitoram este repositório e garantem que o estado do cluster esteja sempre sincronizado com o que
está definido aqui.

## 🚀 Deployments Atuais:

- **`corre-api`**: `corre-api.app.purplebit.com.br`
- **`Argo Workflows UI`**: `argo-workflows.app.purplebit.com.br`
- **`Vault UI`**: `vault.app.purplebit.com.br`
- **`ArgoCD UI`**: `argocd.app.purplebit.com.br`

---

**"O Git é a sua infraestrutura. O cluster é apenas um reflexo."**