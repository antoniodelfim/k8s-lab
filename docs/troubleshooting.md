# Troubleshooting

## Ingress responde "Empty reply from server" em localhost:8080

**Causa:** o manifest oficial do ingress-nginx para `kind` tolera o taint do control-plane, mas não força o agendamento nele via `nodeSelector`. Como o `extraPortMappings` em `kind/cluster-config.yaml` só expõe a porta do host no node control-plane, se o pod do controller cair num worker, o host fica sem rota para o controller.

**Diagnóstico:**
```bash
kubectl get pods -n ingress-nginx -o wide
# Compare a coluna NODE com o node que tem o extraPortMappings
```

**Correção:** forçar o node via label + patch (já incluído em `scripts/up.sh`):
```bash
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' \
  -p '[{"op":"add","path":"/spec/template/spec/nodeSelector/ingress-ready","value":"true"}]'
```

O `kind/cluster-config.yaml` já aplica o label `ingress-ready=true` no control-plane via `kubeadmConfigPatches`.
