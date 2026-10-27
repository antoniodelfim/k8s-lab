# k8s-lab

Laboratório local de Kubernetes usando [kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker), pensado para reproduzir práticas reais de operação e observabilidade em um cluster leve e descartável.

## Por que kind

`kind` roda os nós do cluster como containers Docker, o que torna o ciclo de criar/destruir muito rápido comparado a soluções baseadas em VM, e é o mesmo motor usado por boa parte da comunidade Kubernetes em CI. O cluster definido em [`kind/cluster-config.yaml`](kind/cluster-config.yaml) tem 1 control-plane + 2 workers, simulando uma topologia multi-node mínima.

## Estrutura

```
k8s-lab/
├── kind/                   # configuração do cluster (topologia, port mappings)
├── manifests/
│   ├── apps/               # workloads de exemplo (Deployment, Service, Ingress)
│   └── observability/      # stack de observabilidade (Prometheus/Grafana)
├── scripts/                # automação de ciclo de vida do cluster
└── docs/                   # decisões e notas de operação
```

## Como usar

Pré-requisitos: [Docker](https://docs.docker.com/get-docker/), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), [kubectl](https://kubernetes.io/docs/tasks/tools/).

```bash
# sobe o cluster + ingress-nginx
./scripts/up.sh

# aplica a aplicação de exemplo
kubectl apply -f manifests/apps/hello-world.yaml

# acessa via http://localhost:8080

# derruba o cluster
./scripts/down.sh
```

## GitOps com ArgoCD

Tudo neste cluster é gerenciado via ArgoCD, usando o padrão **app-of-apps**: a única Application aplicada manualmente é [`argocd/root.yaml`](argocd/root.yaml), que sincroniza o restante do diretório `argocd/` (incluindo novas Applications adicionadas depois).

```bash
# bootstrap (uma única vez)
kubectl apply -f argocd/root.yaml
```

Aplicações geridas hoje:

- **hello-world** ([`manifests/apps`](manifests/apps)) — workload de exemplo
- **observability** ([`manifests/observability`](manifests/observability)) — kube-prometheus-stack (Prometheus + Grafana + Alertmanager) instalado via Helm chart referenciado pela Application

Para acessar as UIs, adicione ao `hosts` do seu sistema:

```
127.0.0.1 argocd.k8s-lab.local
127.0.0.1 grafana.k8s-lab.local
```

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| ArgoCD | https://argocd.k8s-lab.local:8443 | admin | `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` |
| Grafana | http://grafana.k8s-lab.local:8080 | admin | admin |

> Nota: o CRD do prometheus-operator aparece como `OutOfSync` no ArgoCD por um diff cosmético de metadata em specs muito grandes — issue conhecida da comunidade, não afeta o estado real (`HEALTH STATUS` permanece `Healthy`). Mitigado via `ignoreDifferences` em [`argocd/app-observability.yaml`](argocd/app-observability.yaml).

## Roadmap

- [x] Cluster multi-node com ingress-nginx
- [x] Workload de exemplo com readiness probe e requests/limits
- [x] Stack de observabilidade (Prometheus + Grafana) via `manifests/observability/`
- [x] GitOps com ArgoCD apontando para este repositório
- [ ] Exemplo de HPA + teste de carga
- [ ] Dashboards customizados no Grafana para o `hello-world`
- [ ] Migração de Ingress-nginx para Gateway API — ver [`docs/gateway-api.md`](docs/gateway-api.md) e [`docs/ingress-nginx-vs-gateway-api.md`](docs/ingress-nginx-vs-gateway-api.md)

## Autor

[Antônio Delfim](https://www.linkedin.com/in/antonio-delfim/) — DevOps/SRE Engineer
