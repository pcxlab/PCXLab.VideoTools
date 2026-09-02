# Terminology

## Purpose

This document defines the preferred terminology used throughout the PCXLab.VideoTools project.

Its purpose is to ensure consistency across:

- Source code
- Documentation
- AI-generated changes
- Future implementations
- Contributor discussions

Terminology should remain stable even if the implementation language changes.

---

# Preferred Terms

Use these terms consistently.

| Preferred | Avoid |
|-----------|------|
| Recording Session | Project |
| Analysis Event | Detection Result |
| Provider | Service |
| Policy | Manager |
| Helper | Utility (when describing project helpers) |
| Timeline | Sequence |
| Keep Block | Clip |
| Cut Block | Removed Clip |
| Rendering | Export (unless referring to an application's UI) |
| Synchronization | Sync Logic |

---

# Naming Principles

Names should:

- Describe intent rather than implementation.
- Be understandable without reading the implementation.
- Remain valid across programming languages.
- Avoid technology-specific wording.

Example:

Good

```
Resolve-PCXSilenceClassification
```

Better than

```
Invoke-RegexProcessing
```

because the first describes the business responsibility.

---

# Documentation Terminology

Documentation should use the same terminology as the source code whenever practical.

Avoid introducing alternate names for the same concept.

---

# Architecture Terminology

Use architecture-focused language.

Examples:

- Business Rule
- Provider
- Policy
- Pipeline
- Stage
- Helper
- Module
- Public API
- Private Helper

Avoid implementation-specific wording unless necessary.

---

# Long-Term Consistency

When introducing new features:

- Reuse existing terminology whenever possible.
- Avoid creating multiple names for the same concept.
- Update Glossary.md if a new architectural term is introduced.

---

# Update Rules

Update this document whenever new terminology becomes part of the project's long-term architecture.

Do not record temporary names or implementation details.

End of document.