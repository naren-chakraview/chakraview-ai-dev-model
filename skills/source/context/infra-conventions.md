# Context: Infrastructure Conventions

> **Template usage:** Fill in project-specific values for all `{placeholder}` items.
> This document is read by Persona 3 (Script Authoring Agent) and Persona 5 (Implementation Agent).

---

## Container Registry

- All images must be pulled from `{internal registry}`, not public registries
- Image tags must be immutable (`{digest or full version tag}`) — no `latest` tags in production

---

## Helm Chart Conventions

- One chart per service, located at `infrastructure/helm/charts/{service}/`
- All configurable values must have a corresponding entry in `values.yaml` with a comment explaining the value
- Chart version follows SemVer; bump patch for template changes, minor for new optional features
- Required templates in every chart: `deployment.yaml`, `service.yaml`, `serviceaccount.yaml`, `networkpolicy.yaml`

---

## Kubernetes Conventions

- Namespace per bounded context: `{project}-{context}`
- All namespaces default to deny-all ingress via NetworkPolicy
- Pod security: `restricted` admission profile on all namespaces
- ResourceQuota and LimitRange in every namespace
- Labels: `app.kubernetes.io/name`, `app.kubernetes.io/part-of`, `app.kubernetes.io/version` required on all resources

---

## IAM / Service Accounts

- One IAM role per service, scoped to the specific resources that service needs
- No wildcard permissions
- `{IAM binding mechanism}`: ServiceAccount name matches service name

---

## Secret Management

- No secrets in Git, environment variables in manifests, or ConfigMaps
- Secrets stored in `{secrets manager}`
- Secrets synced into Kubernetes via `{secrets sync operator}`

---

## CI/CD

- GitOps: all production changes via PR + merge, never manual `kubectl apply`
- Image builds triggered by pushes to `main` only
- Contract validation (`tooling/validate-contracts.sh`) runs on every push, including PRs
- Helm chart changes must pass `helm lint` in CI before merge
