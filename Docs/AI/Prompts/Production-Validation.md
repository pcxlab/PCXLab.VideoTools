# Production Validation Prompt

## Purpose

Use this prompt when validating changes against real production recordings.

Its goals are to:

- Verify that architectural changes behave correctly in real-world scenarios.
- Confirm that unit and regression test results match production behavior.
- Detect issues that synthetic test data may not reveal.
- Preserve production stability.

---

# Prompt

Continue from the current project state.

Before validating:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Known-Issues.md
   - Docs/Testing-Strategy.md

2. Review the scope of the implemented changes.

3. Execute the production validation using representative recording sessions.

4. Compare production results against expected behavior.

5. Distinguish between:

   - Existing baseline issues
   - New regressions
   - Expected behavioral changes

6. Do not classify an issue as a regression unless it can be confirmed.

7. Record unexpected observations separately from confirmed defects.

8. Preserve all production artifacts required for investigation.

9. Update documentation if production validation changes the project's understanding of the system.

---

# Validation Checklist

Verify:

- Analysis results
- Synchronization accuracy
- Editing behavior
- Timeline generation
- Rendered output (if applicable)
- Logging
- Error handling
- Performance observations

---

# Report

Provide only:

- Validation Summary
- Production Results
- Confirmed Issues
- New Regressions
- Recommendations

Clearly distinguish:

- Confirmed
- Suspected
- Not Reproduced

---

# Success Criteria

A successful validation should:

- Increase confidence in production readiness.
- Confirm expected behavior.
- Identify genuine regressions.
- Improve long-term project knowledge.

End of document.