# Bug Investigation Prompt

## Purpose

Use this prompt when investigating unexpected behavior, test failures, production issues, or reported defects.

Its goals are to:

- Identify the root cause.
- Preserve existing behavior whenever possible.
- Avoid introducing unrelated changes.
- Minimize unnecessary repository analysis.
- Keep investigations focused and reproducible.

---

# Prompt

Continue from the current project state.

Before investigating:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Known-Issues.md
   - Docs/Testing-Strategy.md

2. Determine whether the issue is already documented in Known-Issues.md.

3. Read only the architecture documents relevant to the affected subsystem.

4. Avoid repository-wide analysis unless documentation is insufficient.

5. Reproduce the issue before proposing a fix whenever practical.

6. Distinguish clearly between:

   - Confirmed facts
   - Observations
   - Assumptions
   - Hypotheses

7. Identify the most likely root cause before suggesting changes.

8. Keep any proposed fix focused on the identified problem.

9. Avoid refactoring unrelated code during bug fixes.

10. Add or update regression tests when appropriate.

11. Run targeted regression tests after implementing a fix.

12. Update Known-Issues.md if the investigation changes the documented understanding of the issue.

---

# Report

Provide only:

- Root Cause
- Proposed Fix
- Modified Files
- Regression Results

If the cause cannot be confirmed, clearly explain:

- What is known
- What remains uncertain
- Recommended next investigation steps

---

# Success Criteria

A successful investigation should:

- Explain why the issue occurs.
- Avoid speculation.
- Preserve existing behavior outside the affected area.
- Produce a reproducible explanation.
- Improve long-term project knowledge.

End of document.