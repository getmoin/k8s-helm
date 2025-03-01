#!/bin/bash

# Create namespace
kubectl create namespace credential-showcase-ns --dry-run=client -o yaml | kubectl apply -f -

# Create single secret with all credentials
kubectl create secret generic credential-showcase \
    -n credential-showcase-ns \
    --from-literal=API_KEY="$HELLO_WORLD_API_KEY" \
    --from-literal=AUTH_TOKEN="$HELLO_WORLD_AUTH_TOKEN" \
    --from-literal=WEATHER_API_KEY="$WEATHER_API_KEY" \
    --from-literal=DB_PASSWORD="$DB_PASSWORD" \
    --from-literal=RABBIT_PASSWORD="$RABBIT_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -

# Add repositories and update dependencies
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
cd credential-showcase
helm dependency update
cd ..


# Deploy applications
helm upgrade --install credential-showcase ./credential-showcase -f ./credential-showcase/dev-values.yaml

helm upgrade --install frontend-app ./frontend-app \
  --set frontend.image.tag=latest

helm upgrade --install prometheus prometheus-community/prometheus \
  --set server.resources.limits.cpu=100m \
  --set server.resources.limits.memory=128Mi \
  --set server.resources.requests.cpu=50m \
  --set server.resources.requests.memory=64Mi \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false \
  --set server.persistentVolume.enabled=false

echo "Deployment complete!"