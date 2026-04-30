# Script Task: Generate Helm Chart Boilerplate

> **Template usage:** Replace all `{placeholder}` values before running.
> Required substitutions: `{service}`, `{project}`, `{ext}`.

**Task type**: Script (deterministic transformation — Persona 3 produces, Persona 4 runs)
**Script to produce**: `tooling/generate-helm-boilerplate.{ext}`
**Runs in**: CI on service manifest changes; manually when adding a new service

---

## Purpose

Transform the service manifest (`tooling/service-manifest.yaml`) into a Helm chart directory for each service. This transformation is purely mechanical — chart structure follows a fixed template determined by service type (stateful vs stateless) and resource requirements.

---

## Input Schema

Reads `tooling/service-manifest.yaml`. Each service entry has this shape:

```yaml
name: {service}
owner: {team}
language: {language}
type: stateless | stateful
min_replicas: {N}
max_replicas: {N}
resources:
  requests:
    cpu: {millicores}
    memory: {Mi}
  limits:
    cpu: {millicores}
    memory: {Mi}
```

---

## Output

For each service in the manifest, produces `infrastructure/helm/charts/{service}/` with:

```
templates/
  deployment.yaml
  service.yaml
  serviceaccount.yaml
  networkpolicy.yaml
  poddisruptionbudget.yaml   # only if min_replicas > 1
  destinationrule.yaml       # only if service has external HTTP dependencies
values.yaml
Chart.yaml
```

---

## Constraints

1. **Idempotent**: Running twice produces bit-for-bit identical output.
2. **NetworkPolicy in every chart**: Every chart must include a NetworkPolicy template. Default deny-all ingress; allow only explicitly named sources.
3. **PodDisruptionBudget conditionally**: Include only when `min_replicas > 1`. minAvailable = min_replicas - 1.
4. **Resource limits required**: All containers must have both requests and limits set from the manifest values.
5. **No hardcoded values**: All values come from `values.yaml`; templates reference only `.Values.*`.

---

## Acceptance Criteria

- [ ] Script produces one chart directory per service in the manifest
- [ ] Output is idempotent
- [ ] Every chart passes `helm lint`
- [ ] NetworkPolicy present in every chart
- [ ] Script exits non-zero if the manifest is malformed
