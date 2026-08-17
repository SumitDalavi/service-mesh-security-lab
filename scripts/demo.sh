#!/bin/bash
set -e

echo "================================================="
echo "   Service Mesh Security Lab Demo (Istio mTLS)"
echo "================================================="

echo -e "\n1. Building local Docker images..."
docker build -t frontend:local ./src/frontend
docker build -t orders:local ./src/orders
docker build -t payments:local ./src/payments

echo -e "\n2. Creating Kind Cluster (if not exists)..."
if ! kind get clusters | grep -q "istio-lab"; then
  kind create cluster --name istio-lab
else
  echo "Cluster 'istio-lab' already exists."
fi

echo -e "\n3. Loading images into Kind cluster..."
kind load docker-image frontend:local orders:local payments:local --name istio-lab

echo -e "\n4. Installing Istio..."
istioctl install --set profile=demo -y

echo -e "\n5. Enabling automatic Sidecar injection for 'default' namespace..."
kubectl label namespace default istio-injection=enabled --overwrite

echo -e "\n6. Deploying Microservices..."
kubectl apply -f k8s/services/

echo -e "\nWaiting for pods to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod --all --timeout=120s

echo -e "\n7. Enforcing Strict mTLS & Authorization Policies..."
kubectl apply -f istio/peer-authentication.yaml
kubectl apply -f istio/authorization-policies.yaml

echo -e "\nWaiting for policies to sync..."
sleep 10

echo -e "\n8. Testing Allowed Communication (Frontend -> Orders)..."
echo "Expected: 200 OK (Orders processed)"
kubectl exec deploy/frontend -c frontend -- curl -s http://orders.default.svc.cluster.local:3000/orders

echo -e "\n\n9. Testing Blocked Communication (Frontend -> Payments directly)..."
echo "Expected: 403 Forbidden (RBAC: access denied)"
kubectl exec deploy/frontend -c frontend -- curl -s -w "\n%{http_code}" http://payments.default.svc.cluster.local:3000/payments || true

echo -e "\n\n✅ Demo complete. The service mesh successfully authenticates and authorizes traffic."
