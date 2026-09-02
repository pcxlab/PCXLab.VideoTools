# AI Handoff

## Purpose

This document is the primary starting point for every AI assistant and developer working on the PCXLab.VideoTools project.

Its goals are to:

- Minimize repeated repository analysis.
- Preserve architectural knowledge.
- Reduce AI token usage.
- Enable seamless handoff between AI providers.
- Allow multiple developers to work consistently.
- Keep implementation independent from programming language.

This document should be read before making architectural or implementation changes.

---

# Project Overview

**Project Name**

PCXLab.VideoTools

**Current Reference Implementation**

PowerShell 7

**Project Status**

Active Development

**Long-Term Vision**

The current PowerShell implementation is the reference implementation only.

The architecture and business rules must remain portable to future implementations such as:

- JavaScript
- TypeScript
- Python
- Java
- Rust
- C#
- Other languages

The implementation language is never the product.

---

# Read These Documents First

Read only what is necessary.

Always follow this order.

1. AI-Handoff.md
2. Current-State.md
3. Decision-Log.md
4. Known-Issues.md
5. Testing-Strategy.md
6. Coding-Guidelines.md

Read additional Architecture or ADR documents only when they are relevant to the requested work.

Avoid full repository analysis unless absolutely required.

---

# AI Context Strategy

To minimize repeated repository analysis and AI token usage:

- Use this documentation as the primary project knowledge source.
- Read only documents relevant to the current task.
- Do not rediscover architecture that is already documented.
- Continue existing work instead of restarting repository analysis.
- When switching AI providers or starting a new conversation, begin with this documentation before exploring the repository.
- Update documentation whenever architectural knowledge changes.

Documentation is considered part of the source code.

---

# Session Startup Checklist

Before making any code changes:

- Read this document completely.
- Read Current-State.md.
- Read Decision-Log.md.
- Review Known-Issues.md.
- Read only the architecture documents related to the requested task.
- Do not re-analyze the entire repository unless required.
- Verify the current Git branch.
- Confirm the requested scope before implementing.
- Keep the implementation focused on a single logical change.
- Read only the minimum amount of source code required.
- Prefer existing documentation over repository exploration.
- If documentation is missing or outdated, update it before completing the task.

---

# Project Goals

The project aims to build a production-grade video editing platform supporting:

- Media analysis
- Audio synchronization
- Silence detection
- Black-frame detection
- Intelligent editing
- Timeline generation
- Multi-camera synchronization
- Rendering automation

The architecture must remain:

- Maintainable
- Testable
- Modular
- Scalable
- Language independent

---

# Development Principles

Always:

- Preserve existing behaviour.
- Preserve public APIs whenever possible.
- Extract only genuine duplication.
- Avoid speculative abstractions.
- Prefer small focused refactorings.
- Add regression tests.
- Run affected tests before completion.
- Update documentation whenever architecture changes.

Never:

- Rewrite working code without clear benefit.
- Mix unrelated work into the same branch.
- Change public behaviour during refactoring.
- Introduce abstractions used only once.

---

# Branch Strategy

One logical change per branch.

Typical workflow:

main

↓

Create Branch

↓

Implement

↓

Run Tests

↓

Update Documentation

↓

Commit

↓

Merge

↓

Regression Testing

Keep each branch focused on a single architectural improvement.

---

# Expected AI Output

Unless explicitly requested otherwise, provide only:

- Implementation Summary
- Modified Files
- Regression Results

Avoid unnecessary explanations.

---

# AI Responsibilities

Before implementing changes:

- Understand the relevant architecture.
- Reuse existing components.
- Follow naming conventions.
- Preserve backward compatibility.
- Keep the design language independent.
- Update documentation when necessary.

---

# Repository Architecture

High-level processing flow:

Analysis

↓

Synchronization

↓

Editing

↓

Rendering

Business rules must remain independent from the implementation language.

---

# Documentation Responsibilities

Whenever architecture changes:

Update:

- Current-State.md
- Decision-Log.md
- Refactoring-History.md

When workflow changes:

Update:

- AI-Handoff.md

Documentation is part of the implementation.

---

# Long-Term Vision

This documentation is intended to become the permanent knowledge base for the project.

Its purpose is to eliminate repeated repository analysis, reduce AI costs, preserve architectural decisions, and enable smooth collaboration across different AI models, developers, and future language implementations.

---

# Knowledge Base Philosophy

The documentation is the project's primary source of architectural knowledge.

The source code implements the architecture.

The documentation explains the architecture.

When the architecture evolves:

- If you're planning a new architectural direction, update the documentation first.
- If you're making a small implementation change, update the documentation alongside the code.
- Avoid allowing architectural knowledge to exist only in source code.
- Prefer documenting decisions instead of rediscovering them.
- Keep documents implementation-independent whenever possible.

A new AI session should be able to understand the project by reading the documentation before exploring the source code.
