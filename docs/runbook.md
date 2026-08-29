# Runbook — service-mesh-security-lab
> Last updated: 2026-08-29

## Quick Start
```bash
# Execute the full deployment and test suite
bash scripts/demo.sh
```

## Run Tests
```bash
# Run automated policy validation
bash scripts/test_policies.sh
```

## Failure Modes
| Symptom | Cause | Fix |
|---|---|---|
| HTTP 503 from services | Envoy sidecar not ready | Wait for pods to report 2/2 ready. Ensure namespace has `istio-injection=enabled` label |
| HTTP 403 when allowed | Missing Identity | Check if the source pod is running under the correct Kubernetes ServiceAccount |
