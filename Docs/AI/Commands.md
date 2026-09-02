# AI Commands

## Purpose

This document defines a set of standard commands for interacting with AI assistants while working on the PCXLab.VideoTools project.

The goals are to:

- Reduce prompt writing.
- Reduce AI token usage.
- Ensure consistent workflows.
- Preserve architectural standards.
- Allow seamless switching between AI providers.

These commands are conceptual workflows rather than software commands.

---

# /start

## Purpose

Start a new AI development session.

### AI should:

- Read:
  - Docs/00-Index.md
  - Docs/AI/AI-Handoff.md
  - Docs/Current-State.md
  - Docs/Decision-Log.md
  - Docs/Known-Issues.md
- Read only architecture documents relevant to the requested work.
- Avoid repository-wide analysis unless documentation is insufficient.
- Confirm understanding before implementation.

---

# /refactor

## Purpose

Perform one focused architectural refactoring.

### AI should:

- Preserve behavior.
- Preserve public APIs.
- Extract only genuine duplication.
- Add or update tests.
- Run targeted regression tests.
- Update documentation if architecture changes.

Output:

- Implementation Summary
- Modified Files
- Regression Results

---

# /feature

## Purpose

Implement one new feature.

### AI should:

- Review existing architecture.
- Reuse existing helpers and providers.
- Keep implementation modular.
- Add tests.
- Validate behavior.
- Update documentation if necessary.

Output:

- Implementation Summary
- Modified Files
- Tests Added
- Regression Results

---

# /bug

## Purpose

Investigate a defect.

### AI should:

- Reproduce the issue.
- Identify the root cause.
- Separate facts from assumptions.
- Avoid unrelated refactoring.
- Add regression tests if a fix is implemented.

Output:

- Root Cause
- Proposed Fix
- Modified Files
- Regression Results

---

# /review

## Purpose

Review completed work.

### AI should review:

- Architecture
- Maintainability
- Test coverage
- Documentation
- Backward compatibility

Output:

- Review Summary
- Strengths
- Risks
- Recommendation

---

# /test

## Purpose

Validate completed work.

### AI should:

- Recommend the appropriate test scope.
- Distinguish baseline failures from regressions.
- Summarize results.

Output:

- Tests Executed
- Results
- Regressions
- Recommendations

---

# /production

## Purpose

Validate changes using production recordings.

### AI should:

- Compare production behavior with expected behavior.
- Distinguish baseline issues from new regressions.
- Record observations.
- Recommend follow-up work if required.

Output:

- Production Validation Summary
- Confirmed Results
- New Issues
- Recommendations

---

# /docs

## Purpose

Update project documentation.

### AI should:

- Update only the relevant documents.
- Avoid duplication.
- Keep terminology consistent.
- Preserve the responsibility of each document.

Output:

- Documentation Updated
- Files Modified
- Cross-Reference Updates

---

# /migrate

## Purpose

Plan or implement migration to another programming language.

### AI should:

- Preserve architecture.
- Preserve business rules.
- Preserve terminology.
- Use language-appropriate implementation techniques.
- Preserve testing philosophy.

Output:

- Migration Summary
- Risks
- Recommendations

---

# /release

## Purpose

Prepare a change for release or merge.

### AI should verify:

- Tests completed.
- Documentation updated.
- Public APIs reviewed.
- Production validation completed (if applicable).
- Branch is ready to merge.

Output:

- Release Checklist
- Outstanding Items
- Recommendation

---

# Command Philosophy

Commands are intended to reduce prompt length and standardize development workflows.

Rather than rewriting detailed prompts for every session, reference the appropriate command and allow the AI assistant to follow the documented workflow.

Example:

```
/start

Task:

Extract duplicated synchronization helpers.
```

or

```
/bug

Task:

Investigate synchronization confidence dropping below expected thresholds.
```

---

# Long-Term Vision

As the project evolves, additional commands may be introduced.

Existing commands should remain stable whenever practical so that developers and AI assistants share a common workflow across projects, programming languages, and AI providers.

---

End of document.