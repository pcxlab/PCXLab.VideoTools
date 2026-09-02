# Knowledge System

## Purpose

This document explains how the PCXLab.VideoTools knowledge system is organized and how it should be used by developers and AI assistants.

Rather than relying on repeated repository analysis, the project captures long-term architectural knowledge in documentation. This reduces onboarding time, lowers AI token usage, and ensures that important decisions remain available regardless of the implementation language or AI provider.

---

# Guiding Philosophy

The repository is organized around three layers of knowledge:

1. Documentation
2. Architecture
3. Implementation

Documentation is the primary source of project knowledge.

Architecture defines how the project is designed.

Implementation is one realization of that architecture.

This relationship can be represented as:

Project Knowledge

↓

Documentation

↓

Architecture

↓

Business Rules

↓

Implementation

---

# Goals

The knowledge system exists to:

- Preserve architectural decisions.
- Reduce repeated repository analysis.
- Reduce AI token consumption.
- Improve developer onboarding.
- Support multiple AI providers.
- Support multiple contributors.
- Preserve knowledge across programming language migrations.

---

# Reading Strategy

Read only what is necessary.

Recommended order:

1. Docs/00-Index.md
2. Docs/AI/AI-Handoff.md
3. Docs/Current-State.md
4. Docs/Decision-Log.md
5. Docs/Known-Issues.md
6. Docs/Testing-Strategy.md
7. Docs/Coding-Guidelines.md

Read Architecture and ADR documents only when they relate to the current task.

Avoid repository-wide analysis unless documentation cannot answer the question.

---

# Responsibilities of Each Document

## 00-Index.md

Navigation entry point for the documentation.

---

## AI-Handoff.md

Primary startup guide for AI assistants and developers.

---

## Current-State.md

Describes the project as it exists today.

---

## Decision-Log.md

Records important architectural decisions.

---

## Known-Issues.md

Tracks confirmed baseline issues and ongoing investigations.

---

## Refactoring-History.md

Records completed architectural improvements.

---

## Testing-Strategy.md

Defines the project's testing philosophy and validation approach.

---

## Coding-Guidelines.md

Defines coding conventions and architectural expectations.

---

## Contributor-Workflow.md

Describes the recommended development workflow.

---

## Release-Checklist.md

Defines the steps required before releasing or merging significant changes.

---

## Glossary.md

Defines common project terminology.

---

## Terminology.md

Defines preferred naming conventions.

---

## Project-Vision.md

Describes the long-term direction of the project.

---

## AI Prompt Library

Provides reusable prompts for common development activities, including:

- Architecture refactoring
- Bug investigation
- Feature implementation
- Production validation
- Documentation updates
- Language migration
- Code review

---

# Documentation Update Rules

Documentation should evolve with the project.

Update documentation when:

- Architecture changes.
- Business rules change.
- New terminology is introduced.
- Development workflow changes.
- Long-term knowledge changes.

Avoid updating documentation for temporary implementation details.

---

# AI Usage Principles

AI assistants should:

- Read documentation before analyzing source code.
- Reuse existing architecture.
- Preserve project terminology.
- Keep changes focused.
- Avoid speculative abstractions.
- Update documentation when required.

AI should use documentation as the primary knowledge source rather than rediscovering information already recorded.

---

# Multi-Language Vision

The project is designed so that:

- Business rules remain stable.
- Architecture remains recognizable.
- Documentation remains applicable.

Only the implementation should change when moving to another programming language.

This allows future implementations in JavaScript, TypeScript, Python, Java, Rust, Go, C#, or other languages without redesigning the project.

---

# Multi-Contributor Vision

The knowledge system enables multiple developers and AI assistants to work consistently by providing a shared understanding of:

- Architecture
- Terminology
- Workflow
- Testing
- Design decisions

Knowledge should remain with the project rather than with individual contributors.

---

# Long-Term Vision

The documentation should eventually become complete enough that a new contributor or AI assistant can understand the project primarily by reading the documentation, consulting the source code only when implementation details are required.

Success is measured not by the size of the documentation, but by its ability to reduce repeated analysis while preserving architectural understanding.

---

# Version

Knowledge System Version: 1.0

---

End of document.