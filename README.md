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

## Roadmap

- [x] Cluster multi-node com ingress-nginx
- [x] Workload de exemplo com readiness probe e requests/limits
- [ ] Stack de observabilidade (Prometheus + Grafana) via `manifests/observability/`
- [ ] GitOps com ArgoCD apontando para este repositório
- [ ] Exemplo de HPA + teste de carga

## Autor

[Antônio Delfim](https://www.linkedin.com/in/antonio-delfim/) — DevOps/SRE Engineer
