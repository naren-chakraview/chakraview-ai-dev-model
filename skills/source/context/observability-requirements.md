> **Template**: Fill in all `{placeholder}` values before running any Chakraview skills. This file is copied to `ai-agents/context/observability-requirements.md` in your project.

# Context: Observability Requirements

> **Template usage:** Replace all `{placeholder}` items with project-specific values before using this document.
> Required substitutions: `{service}` (repeat for each service), `{messaging system}` (e.g. Kafka, RabbitMQ), `{SDK language}` (e.g. TypeScript, Python), `{instrumentation file}`.

Every service implementation produced by an AI agent must meet these requirements. These are not optional. A service that does not register the required metrics cannot have its SLA measured, which means it cannot be operated safely.

---

## Required Metrics (all services)

Every service must register these metrics using the OpenTelemetry SDK. Metric names are fixed — SLO queries in `observability/slos/` depend on them.

| Metric name | Type | Labels | Description |
|---|---|---|---|
| `{service}_requests_total` | Counter | `method`, `route`, `status_code` | Total HTTP requests; used for availability SLO error rate |
| `{service}_errors_total` | Counter | `reason`, `route` | Total errors; `reason` is one of: `validation`, `domain`, `infrastructure`, `timeout` |
| `{service}_request_duration_seconds` | Histogram | `method`, `route`, `status_code` | Request duration; buckets derived from SLA `latency_p99_ms` |

Where `{service}` = the service name defined in `tooling/service-manifest.yaml`.

### Histogram Bucket Requirements

Buckets must include a boundary at the SLA `latency_p99_ms` target (divided by 1000 to convert to seconds) so the SLO query has a meaningful bucket at the threshold.

| Service | p99 target | Required bucket |
|---|---|---|
| {service} | {p99 target ms} | {p99 target / 1000} |
| {service} reads | {p99 target ms} | {p99 target / 1000} |
| {service} writes | {p99 target ms} | {p99 target / 1000} |

Standard additional buckets: `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5]`

---

## Required Business Metrics (per service)

For each service, define the domain-specific counters, gauges, and histograms that reflect business activity. Examples of the pattern:

### {Service A}

| Metric | Type | Labels | Description |
|---|---|---|---|
| `{service_a}_{event}_total` | Counter | `{dimension}` | {Description of what this counts} |
| `{service_a}_{operation}_duration_seconds` | Histogram | `outcome` (success/compensation) | End-to-end {operation} duration |
| `{service_a}_{compensating_action}_total` | Counter | `reason` | {Compensating action} triggered |

### {Service B}

| Metric | Type | Labels | Description |
|---|---|---|---|
| `{service_b}_{event}_total` | Counter | `outcome` (success/rejected/expired) | {Description of what this counts} |
| `{service_b}_{resource}_level` | Gauge | `{dimension}` | Current {resource} level (limit cardinality — avoid unbounded label values) |
| `{service_b}_projection_lag_seconds` | Gauge | — | {Read model} lag behind {write model} |

### {Service C}

| Metric | Type | Labels | Description |
|---|---|---|---|
| `{service_c}_{event}_total` | Counter | `{dimension}` | {Description of what this counts} |
| `{service_c}_{action}_total` | Counter | `reason` | {Action} events |

---

## Required Trace Spans

Every inbound HTTP request must produce a trace span with:
- `http.method`, `http.route`, `http.status_code` attributes (auto-injected by OTEL Operator)
- `service.name` resource attribute = the Kubernetes service name
- `deployment.environment` resource attribute = `staging` or `production`

{Messaging system} consumer handlers must produce a child span with:
- `messaging.system` = `{messaging system}`
- `messaging.destination` = topic name
- `messaging.operation` = `receive`

---

## Required Log Fields

Every log entry must include these fields as structured JSON:

```json
{
  "timestamp": "ISO 8601 UTC",
  "level": "info | warn | error",
  "service": "{service}",
  "traceId": "hex string from active span",
  "spanId": "hex string from active span",
  "msg": "human-readable message"
}
```

Do not log PII ({examples of PII relevant to the domain}) in structured fields. Use obfuscation helpers from `ai-agents/context/coding-standards.md`.

---

## OTEL SDK Initialization Pattern

All services must initialize OTEL using the following pattern (from `coding-standards.md`):

```{SDK language}
// {instrumentation file} — initialize before any other imports
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-grpc';
import { PrometheusExporter } from '@opentelemetry/exporter-prometheus';

// SDK is initialized once at process start.
// All instruments (counters, histograms) are registered here, not in business logic.
```

Instruments are created once at module load time. Do not create new instruments per request.
