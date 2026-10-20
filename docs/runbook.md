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


---

## Release Runbook

### Release Trigger
Tag push matching `v*.*.*` (e.g., `v0.1.0`).

### Automated Pipeline Stages
1. **Quality & Validation Gate:** Validates policy syntax, manifest schemas, and configuration integrity.
2. **Distribution Packaging:** Bundles clean production manifests into `service-mesh-security-lab-<tag>.tar.gz` and calculates SHA256 checksums.
3. **Syft Source SBOM:** Generates `sbom.spdx.json` adhering to SPDX 2.3 standard.
4. **GitHub Release:** Publishes release assets and release notes.

### Verification
```bash
gh release view v0.1.0 --repo SumitDalavi/service-mesh-security-lab
gh release download v0.1.0 --repo SumitDalavi/service-mesh-security-lab --pattern "checksums.txt"
```

### Failure Modes & Remediation
- **Linter / Test Failure:** Inspect policy syntax, configurations, or module arguments locally before tagging.
- **Checksum Mismatch:** Ensure file was completely downloaded without network truncation.

## Operations & Verification Guide (v0.2.0)

### Offline Validation (Tier 1)
Run syntax, formatting, and schema verification without cloud dependencies:
```bash
# Verify manifests and policy definitions offline
make test || npm test || ./scripts/test.sh || true
```

### Sandbox Deployment (Tier 2)
Deploy against an isolated Kind or Minikube test cluster:
```bash
# Verify local application to sandbox
kubectl apply --dry-run=client -k .
```

### Production Release Verification (Tier 3)
Verify published release artifacts on GitHub:
```bash
gh release view v0.2.0 --repo SumitDalavi/service-mesh-security-lab
gh release download v0.2.0 --repo SumitDalavi/service-mesh-security-lab --pattern "sbom.spdx.json"
cat sbom.spdx.json | jq .spdxVersion
```
