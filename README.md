# datapains-argo-cd-k8s

## Workshops

### Trino on K8S
This workshop is a continuation off: [Deploy Trino on Kubernetes: Helm Setup with Hive Metastore & MinIO Integration](https://medium.com/@simon.thelin90/trino-minio-metastore-workshop-kubernetes-dbede7b1eca1)

[Medium Article](https://medium.com/@simon.thelin90/second-edition-argocd-deploy-trino-on-kubernetes-helm-setup-with-hive-metastore-minio-768e51fe84f7) Covering this repo.

## Pre requisites

* docker-desktop with kubernetes enabled

## Setup

### Local

Set for your environment `~/.baschrc` or `~/.zshrc` or in the session where you run this.

```bash
export HELM_EXPERIMENTAL_OCI=1
```

```bash
helm repo add argo https://argoproj.github.io/argo-helm
```

`List version`
```bash
helm search repo argo-cd
```

Time of writing this using `7.3.4`.

## Core
```bash
make deploy-local-argocd 
```

Get password for `UI`.
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Run
```bash
kubectl port-forward service/datapains-argocd-server -n argocd 8080:443
```

You can now login into the `UI` with:

[ArgoCD UI](localhost:8080)
* user: admin
* password: <output from get secret above>

## Applications

### Airbyte

```bash
make create-secret REPO_URL=git@github.com:Thelin90/datapains-airbyte.git SECRET_NAME=datapains-airbyte-creds SSH_KEY_PATH=<path-to-id_rsa>
```

```bash
make apply-argocd-app REPO_NAME=datapains-airbyte APP_NAME=airbyte
```

`Note deployment can take a few minutes, check in argocd UI!`.

#### Access UI
`UI` is now accessible via: wwww.localhost:32767

### Apache Superset

```bash
make create-secret REPO_URL=git@github.com:Thelin90/datapains-bi-tools.git SECRET_NAME=datapains-bi-tools-creds SSH_KEY_PATH=<path-to-id_rsa>
```

```bash
make apply-argocd-app REPO_NAME=datapains-bi-tools APP_NAME=superset
```

`Port Forward`

```bash
kubectl port-forward svc/superset 8088:8088 -n superset
```

### Argo Workflow

```bash
make create-secret REPO_URL=git@github.com:Thelin90/datapains-argo-workflow.git SECRET_NAME=datapains-argo-workflow-creds SSH_KEY_PATH=<path-to-id_rsa>
```

```bash
make apply-argocd-app REPO_NAME=datapains-argo-workflow APP_NAME=argo-workflow
```

`Note deployment can take a few minutes, check in argocd UI!`.

#### Access UI
`UI` is now accessible via: wwww.localhost:32767

### Prometheus Community

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

```bash
helm repo update
```

### kube-prometheus-stack

* prometheus operator
* grafana

```bash
make apply-argocd-app REPO_NAME=datapains-monitoring APP_NAME=kube-prometheus-stack
```

`Note deployment can take a few minutes, check in argocd UI!`.

### Spark Operator

First add `spark` namespace.

```bash
kubectl create namespace spark
```

```bash
make apply-argocd-app REPO_NAME=datapains-spark-operator APP_NAME=spark-operator
```

### DataPains Trino K8S

We will deploy trino through argocd, the repo we have available on [datapains-trino-k8s](https://github.com/Thelin90/datapains-trino-k8s)

You will have to setup a [secret key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

Create your secret based on your github `SSH` key.
```bash
 make create-secret REPO_URL=git@github.com:Thelin90/datapains-trino-k8s.git SECRET_NAME=datapains-trino-k8s-creds SSH_KEY_PATH=<path-to-id_rsa>
 ```

`NOTE!`

Remember to build the hive metastore image, instructions [here](https://github.com/Thelin90/datapains-trino-k8s/tree/main?tab=readme-ov-file#docker).

Now deploy the metastore:
```bash
make apply-argocd-app REPO_NAME=datapains-trino-k8s APP_NAME=metastore
```

Now deploy trino, once you see it being healthy in ArgoCD UI.
```bash
make apply-argocd-app REPO_NAME=datapains-trino-k8s APP_NAME=trino
```
