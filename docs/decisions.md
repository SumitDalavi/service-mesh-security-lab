# Decisions

## ADR-001: Istio over NetworkPolicies for Zero-Trust
**Date:** 2026-08-29  
**Status:** Accepted

**Context:**  
We need to secure East-West traffic between microservices and enforce least-privilege access.

**Decision:**  
We chose Istio `AuthorizationPolicy` instead of Kubernetes `NetworkPolicy`.

**Consequences:**  
- ✅ Authentication is based on cryptographic SPIFFE ID (ServiceAccounts) rather than IP addresses, which are ephemeral.
- ✅ Traffic is automatically encrypted (mTLS) without application code changes.
- ⚠️ Adds latency (Envoy proxy overhead) and complexity (Control Plane management).

## ADR-002: Multi-Tier Verification & OCI Dual Distribution
- **Context:** Declarative infrastructure and policy catalogs required robust local simulation gates without imposing cloud provider dependencies or credentials during CI/CD.
- **Decision:** Establish a strict 3-tier verification model (offline linting → sandbox cluster test → GitOps deployment) and distribute validated release packages with SBOMs and OCI container/chart registries.
- **Consequences:** 
  - *Pros:* Zero cloud credentials required for CI validation; verifiable supply-chain integrity via Syft SBOMs.
  - *Cons:* Requires maintaining local test fixtures and mock plan inputs.
