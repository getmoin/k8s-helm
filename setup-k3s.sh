#!/bin/bash

sudo apt update && sudo apt upgrade -y

curl -sfL https://get.k3s.io | sh -

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "Waiting for K3s to be ready..."
sleep 30
kubectl get nodes

sudo kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml

echo "Waiting for cert-manager to be ready..."
sleep 30
sudo kubectl get pods -n cert-manager

cat <<EOF | sudo kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-key
    solvers:
    - http01:
        ingress:
          class: traefik
EOF

echo "K3s and cert-manager setup complete!"