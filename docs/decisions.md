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
