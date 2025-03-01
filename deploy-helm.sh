#!/bin/bash

# Create namespace and secrets if they don't exist
create_secret_if_not_exists() {
    local secret_name=$1
    local namespace=$2
    local secret_value=$3
    local secret_key=$4
    if ! kubectl get secret $secret_name -n $namespace &> /dev/null; then
        echo "Creating secret: $secret_name"
        kubectl create secret generic $secret_name -n $namespace \
            --from-literal=$secret_key=$secret_value
    else
        echo "Secret $secret_name already exists, skipping creation"
    fi
}
kubectl create namespace credential-showcase-ns --dry-run=client -o yaml | kubectl apply -f -
create_secret_if_not_exists "hello-world-api-key" "credential-showcase-ns" "$HELLO_WORLD_API_KEY" "API_KEY"
create_secret_if_not_exists "hello-world-auth-token" "credential-showcase-ns" "$HELLO_WORLD_AUTH_TOKEN" "AUTH_TOKEN"
create_secret_if_not_exists "weather-api-key" "credential-showcase-ns" "$WEATHER_API_KEY" "WEATHER_API_KEY"
create_secret_if_not_exists "db-creds" "credential-showcase-ns" "$DB_PASSWORD" "DB_PASSWORD"
create_secret_if_not_exists "rabbit-creds" "credential-showcase-ns" "$RABBIT_PASSWORD" "RABBIT_PASSWORD"


# Add repositories and create charts
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