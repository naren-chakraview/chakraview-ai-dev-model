---
title: Case Studies
description: Projects built using the Chakraview AI Dev Model.
---

# Case Studies

## chakraview-enterprise-modernization

**Challenge:** Modernise a Java EE e-commerce monolith to cloud-native microservices without downtime.

**Personas used:** All 6 — Human Domain Expert authored SLAs, domain invariants, and event schemas; Documentation Agent wrote ADRs and domain models; Script Authoring Agent wrote the SLO→alert pipeline and infrastructure scaffold generators; Script Executor ran them in CI; Implementation Agent built service skeletons from contracts; Compliance Agent reviewed each phase against ADR/principle checks.

**Key outcomes:**
- 15 Architecture Decision Records produced by Personas 1 + 2
- SLA→alert pipeline: 5 SLA files → 5 SLO definitions → 5 burn rate alert manifests, deterministically
- 4 service implementations built from contracts by Persona 5
- Zero contract violations at merge time for all services (Persona 6 compliance gate)

**Read more:** [How This Project Was Built](https://naren-chakraview.github.io/chakraview-enterprise-modernization/how-this-was-built/)

**Repository:** [github.com/naren-chakraview/chakraview-enterprise-modernization](https://github.com/naren-chakraview/chakraview-enterprise-modernization)
