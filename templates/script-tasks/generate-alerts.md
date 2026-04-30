# Script Task: Generate Burn Rate Alerts

> **Template usage:** Replace `{alerting-system}`, `{ext}`, `{CI system}`, `{project}`, `{runtime}`, `{yaml library}`, `{manifest validator}` with project-specific values.

**Task type**: Script (deterministic transformation)
**Script to produce**: `tooling/generate-{alerting-system}-rules.{ext}`
**Runs in**: {CI system}, manually by engineers

---

## Purpose

Transform SLO definition YAML files into {alert manifests} using Google's multi-window burn rate alerting model. This transformation is purely mechanical — no judgment required — so it should be a script, not an agent invocation.

---

## Input Schema

Reads all `observability/slos/{service}-slo.yaml` files. Each file has this shape:

```yaml
service: {service}
window_days: 30
availability:
  target: {availability target, e.g. 0.9995}
  metric: {service}_requests_total
  error_metric: {service}_errors_total
latency:
  target_p99_ms: {ms, e.g. 500}
  histogram_metric: {service}_request_duration_seconds
```

---

## Output

For each input SLO file, produces `observability/alerts/{service}-burnrate.yaml`. Example output structure:

```yaml
# Example (Prometheus/Kubernetes)
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {service}-slo-burnrate
  namespace: {project}-platform
spec:
  groups:
    - name: {service}.slo.burnrate
      rules:
        # Fast burn: page immediately (budget gone in < 2 days at this rate)
        - alert: {Service}SLOFastBurn
          expr: |
            (
              sum(rate({service}_errors_total[1h])) /
              sum(rate({service}_requests_total[1h]))
            ) > (14.4 * {error_rate_threshold})
          for: 2m
          labels:
            severity: page
            service: {service}
          annotations:
            summary: "{Service} SLO fast burn rate: error budget depleting rapidly"
            runbook_url: "docs/runbooks/sla-breach-response.md"
        # Slow burn: ticket (budget gone in < 5 days)
        - alert: {Service}SLOSlowBurn
          expr: |
            (
              sum(rate({service}_errors_total[6h])) /
              sum(rate({service}_requests_total[6h]))
            ) > (6 * {error_rate_threshold})
          for: 15m
          labels:
            severity: ticket
            service: {service}
```

---

## Algorithm

```
for each observability/slos/{service}-slo.yaml:
  error_rate_threshold = 1 - availability.target
  fast_burn_factor = 14.4   # budget exhausted in 30d/14.4 = 2.08 days
  slow_burn_factor = 6      # budget exhausted in 30d/6 = 5 days

  emit {alert manifests} with:
    - fast burn alert: 1h window, factor=14.4, severity=page
    - slow burn alert: 6h window, factor=6, severity=ticket
    - latency alert: histogram_quantile(0.99, ...) > target_p99_ms/1000
```

---

## Idempotency

Running the script twice produces identical output. If an SLO file has not changed since the last run, the corresponding alert file is unchanged (bit-for-bit identical, enabling git diff checks in CI).

---

## Acceptance Criteria

- [ ] Script runs with `{runtime} tooling/generate-{alerting-system}-rules.{ext}` from repo root
- [ ] Produces one output file per input SLO file
- [ ] Output is valid YAML (parseable by `{yaml library}`)
- [ ] Output is valid {alert manifests} (validate with `{manifest validator}`)
- [ ] Idempotent: running twice produces identical output
- [ ] Exits non-zero if any SLO file is malformed
