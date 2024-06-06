#!/bin/bash

set -e

REPO_URL=$1
SECRET_NAME=$2
NAMESPACE=$3
SSH_KEY_PATH=$4

create_secret() {
    local private_key=$(<"$SSH_KEY_PATH")

    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: "$SECRET_NAME"
  namespace: "$NAMESPACE"
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: "$REPO_URL"
  sshPrivateKey: |
$(echo "$private_key" | sed 's/^/    /')
EOF
}

create_secret

echo "Kubernetes secret created successfully."
