# Context: Coding Standards

> **Template usage:** Fill in project-specific values for all `{placeholder}` items.
> This document is read by all agent tasks. Keep it up to date as standards evolve.

---

## Language and Runtime

- **Language**: {language and version}
- **Runtime**: {runtime}
- **Formatter**: {formatter} — all code must pass formatter check with zero changes
- **Type checker**: {type checker} — all code must pass with zero errors. `{dynamic type equivalent}` is prohibited in domain layer files.

---

## File Structure

- One {class/struct/module} per file, named identically to the {class/struct/module}
- Domain layer files may not import from infrastructure layer files
- Application layer files may import from domain layer only
- Infrastructure layer files may import from both

---

## Error Handling

- Domain errors are named {error class type} with a descriptive name (e.g., `InvalidTransitionError`, not `Error`)
- Infrastructure errors are wrapped in a domain error before being raised out of the infrastructure layer
- No swallowed errors: every caught error is either re-raised or logged with the full original error attached

---

## Naming

- Files: `{naming convention}` (e.g., PascalCase for classes, kebab-case for modules)
- Functions/methods: `{naming convention}`
- Constants: `{naming convention}`
- Test files: `{naming convention}` (e.g., `{ClassName}.test.{ext}`)

---

## Testing

- One test file per domain class, located at `services/{service}/tests/domain/`
- Each invariant in `contracts/domain-invariants/{service}-invariants.md` must have a named test that would fail if the invariant were violated
- Test names reference the invariant ID: `test_{INV-ID}_{description}`
- No mocking of domain layer internals — test domain classes directly

---

## Comments

- No inline comments explaining what code does — the code should do that
- Comments are permitted only for non-obvious WHY (a hidden constraint, a workaround for a specific external bug)
- No TODO comments in merged code — open a ticket instead
