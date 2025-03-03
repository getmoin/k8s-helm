#!/bin/bash

# Add repositories and update dependencies
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
cd credential-showcase
helm dependency update
cd ..

# Deploy applications
# helm upgrade --install credential-showcase ./credential-showcase -f ./credential-showcase/dev-values.yaml

helm upgrade --install credential-showcase ./credential-showcase \
  -f ./credential-showcase/dev-values.yaml \
  --set services[0].env.API_KEY="$HELLO_WORLD_API_KEY" \
  --set services[0].env.AUTH_TOKEN="$HELLO_WORLD_AUTH_TOKEN" \
  --set services[1].env.WEATHER_API_KEY="$WEATHER_API_KEY" \
  --set services[1].env.DB_PASSWORD="$DB_PASSWORD" \
  --set services[1].env.RABBIT_PASSWORD="$RABBIT_PASSWORD" \
  --set postgresql.auth.password="$DB_PASSWORD" \
  --set rabbitmq.auth.password="$RABBIT_PASSWORD"

helm upgrade --install showcase-ui ./showcase-ui -f ./showcase-ui/dev-values.yaml
  --set services[0].env.BACKEND_API_KEY="$BACKEND_API_KEY" \
  --set services[0].env.AUTH_TOKEN="$UI_AUTH_TOKEN"

# helm upgrade --install prometheus prometheus-community/prometheus \
#   --set server.resources.limits.cpu=100m \
#   --set server.resources.limits.memory=128Mi \
#   --set server.resources.requests.cpu=50m \
#   --set server.resources.requests.memory=64Mi \
#   --set alertmanager.enabled=false \
#   --set pushgateway.enabled=false \
#   --set server.persistentVolume.enabled=false

echo "Deployment complete!"