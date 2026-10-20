> **NOTE:** This repository is an archival lab or partial prototype. It is not actively maintained and should not be used as a reference for production-grade deployments or performance benchmarks.


# Service Mesh Security Lab (Istio + mTLS)

[![Release](https://img.shields.io/github/v/release/SumitDalavi/service-mesh-security-lab)](https://github.com/SumitDalavi/service-mesh-security-lab/releases)
[![Release Workflow](https://github.com/SumitDalavi/service-mesh-security-lab/actions/workflows/release.yml/badge.svg)](https://github.com/SumitDalavi/service-mesh-security-lab/actions/workflows/release.yml)


> **Maturity:** Lab / Reference Implementation
> _A portfolio project demonstrating zero-trust networking between microservices using Istio. This lab focuses on mutual TLS (mTLS), fine-grained authorization policies, and traffic observability at the mesh layer._

## The Problem
Kubernetes NetworkPolicies control which pods *can* talk to which pods, but they don't verify *who* is talking — there's no cryptographic identity behind service-to-service calls, and traffic is unencrypted in-cluster by default. As microservice counts grow, teams need automatic mutual authentication and centralized authorization without modifying application code.

## The Solution
This project deploys a 3-tier microservice architecture into a local Kubernetes cluster secured by the Istio service mesh. It enforces strict mTLS and validates inter-service communication through identity-based AuthorizationPolicies.

```text
       (Allows Any)                 (Allows 'frontend' SA)         (Allows 'orders' SA)
          │                                 │                              │
          ▼                                 ▼                              ▼
+-------------------+             +-------------------+          +-------------------+
|                   |    mTLS     |                   |   mTLS   |                   |
|   Frontend Pod    | ──────────▶ |    Orders Pod     | ────────▶|   Payments Pod    |
| (Envoy Sidecar)   |             |  (Envoy Sidecar)  |          |  (Envoy Sidecar)  |
|                   |             |                   |          |                   |
+-------------------+             +-------------------+          +-------------------+
          │                                                                ▲
          │                          (DENIES 'frontend' SA)                │
          └────────────────────────────────────────────────────────────────┘
                                        (Blocked)
```

## Why This Over the Obvious Alternative
Application-level TLS termination requires every team to implement and maintain certificate handling correctly — a common source of misconfiguration. Istio's sidecar-based mTLS provides transparent, centrally-managed encryption and identity without any application code changes, which is the pattern large-scale platform teams standardize on.

## Tech Stack
- **Service Mesh:** Istio
- **Orchestration:** Kubernetes (kind for local dev)
- **Sample Services:** Node.js/Express (Lightweight call chain)
- **Observability:** Kiali, Jaeger, Prometheus (Istio's built-in addons - deployable via Istio profiles)
- **Policy:** Istio PeerAuthentication + AuthorizationPolicy CRDs

## Decision Log

| Component | Decision | Rationale |
| :--- | :--- | :--- |
| **Service Mesh** | Istio | Industry standard for implementing zero-trust architectures in Kubernetes. |
| **Local Cluster** | kind | Provides a lightweight, disposable Kubernetes environment for testing Istio without cloud costs. |
| **Policy Definition** | Istio AuthorizationPolicies | Allows defining Layer 7 rules based on cryptographic SPIFFE identities (ServiceAccounts) rather than fragile IP addresses. |

## Project Structure

```text
service-mesh-security-lab/
├── docs/                 # Architecture documentation (Istio Identity Model)
├── istio/                # mTLS and AuthorizationPolicy manifests
├── k8s/                  # Kubernetes Deployments, Services, and ServiceAccounts
├── scripts/              # Automated demo script
├── src/                  # Node.js source code for the 3 sample services
└── README.md             # This file
```

## Prerequisites

| Tool | Purpose |
| :--- | :--- |
| Docker | Building images and running the local cluster |
| kind (Kubernetes in Docker) | Provisioning the local Kubernetes cluster |
| kubectl | Interacting with the cluster |
| istioctl | Installing and managing Istio |

## Step-by-Step Setup

1. **Clone the repository and enter the directory:**
   ```bash
   git clone https://github.com/your-username/service-mesh-security-lab.git
   cd service-mesh-security-lab
   ```

2. **Run the automated setup and demo script:**
   ```bash
   ./scripts/demo.sh
   ```
   *Alternatively, follow the manual steps in the script to build images, create the kind cluster, install Istio, and apply the manifests.*

## Usage & Demo

The `demo.sh` script automates the deployment and testing, demonstrating the following scenarios:

### Scenario 1: Allowed Call (Frontend -> Orders)
The `frontend` pod makes an HTTP request to the `orders` service. Envoy intercepts the request, establishes an mTLS connection, and the `orders` pod's AuthorizationPolicy validates the `frontend` ServiceAccount identity. The request succeeds.

### Scenario 2: Blocked Call (Frontend -> Payments)
The `frontend` pod attempts to bypass the `orders` service and calls `payments` directly. The `payments` service has an AuthorizationPolicy explicitly requiring the `orders` ServiceAccount identity. The request is rejected by the Envoy proxy with a `403 Forbidden` error (RBAC: access denied).

## Verification

| Check | Expected Result |
| :--- | :--- |
| Sidecar Injection | `kubectl get pods` shows `2/2` ready containers for all services. |
| mTLS Enforcement | `istioctl analyze` reports no validation errors on `peer-authentication.yaml`. |
| Authorization | `curl` from `frontend` to `payments` returns `403 Forbidden`. |

## 🛠️ Verification & Deployment Tiers

This service mesh security lab supports progressive validation from local mock services to cluster-wide strict mTLS enforcement.

### Tier 1: Local Mock Service Verification (Default)
Run client and service components locally in mock mode without Istio sidecars.
- **Execution:** Start services with default configuration: `npm test` or local Docker.
- **Behavior:** Demonstrates application communication and protocol handling without service mesh dependencies.

### Tier 2: Local Istio / Kind Mesh Testing
Deploy into a local Kind cluster with Istio service mesh enabled.
- **Execution:** `kubectl apply -f istio/` to enable `PeerAuthentication` and sidecar injection.
- **Behavior:** Verifies automatic mTLS certificate exchange, traffic authorization policies, and telemetry.

### Tier 3: Production Zero-Trust Mesh Deployment
Enforce STRICT mTLS across multi-tenant production Kubernetes namespaces.
- **Distribution:** Release assets and verified SPDX SBOM available on [GitHub Releases](https://github.com/SumitDalavi/service-mesh-security-lab/releases).


## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md) — How Istio Identity and AuthZ work
- [Runbook](docs/runbook.md) — Setup, commands, and expected outputs
- [Decisions](docs/decisions.md) — ADRs for Zero-Trust networking
- [Changelog](docs/changelog.md) — Change history

## Mock Boundaries (Honest Scope)

| What | Status | Details |
|---|---|---|
| Istio Control Plane | **Real** | Standard `istiod` deployment on local `kind`. |
| Zero-Trust Policies | **Real** | `AuthorizationPolicy` and `PeerAuthentication` CRDs are strictly enforced by Envoy. |
| Target Workloads | **Simulated** | Node.js mock services used to simulate a 3-tier architecture instead of a heavy real-world app. |

## 🔗 Related Projects

- [`k8s-gateway-api-platform`](../k8s-gateway-api-platform/) — Handles North-South traffic into the cluster before Istio manages the East-West traffic.

## Author

**Sumit Dalavi — Senior DevSecOps / Platform Engineer**
- [GitHub](https://github.com/SumitDalavi)
- [LinkedIn](https://in.linkedin.com/in/sumit-dalavi-762838129)

---

## Release & Security Verification

This repository is published as an immutable release catalog under the portfolio release standard:

- **Release Artifacts:** Authenticated distribution bundle (`service-mesh-security-lab-v0.1.0.tar.gz`) containing production policies, modules, and manifests.
- **Cryptographic Integrity:** SHA-256 integrity hash provided in `checksums.txt`.
- **Software Bill of Materials (SBOM):** Fully compliant SPDX JSON SBOM (`sbom.spdx.json`) generated by Anchore Syft.

### Verification Commands
```bash
# 1. View Release Metadata
gh release view v0.1.0 --repo SumitDalavi/service-mesh-security-lab

# 2. Download Release Assets & Verify SHA256 Checksum
gh release download v0.1.0 --repo SumitDalavi/service-mesh-security-lab --pattern "*.tar.gz" --pattern "checksums.txt"
sha256sum -c checksums.txt

# 3. Inspect SPDX SBOM
gh release download v0.1.0 --repo SumitDalavi/service-mesh-security-lab --pattern "sbom.spdx.json"
cat sbom.spdx.json | jq .spdxVersion
```
