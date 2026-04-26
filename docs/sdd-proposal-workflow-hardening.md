# SDD Proposal: Docs/Workflow Hardening

## Intent
Harden existing skills and define a standard for future skills to ensure high-quality execution by AI agents, including those with weaker reasoning capabilities.

## Scope
### In
- Refactor `dev-skills/repo-bootstrap/SKILL.md` to introduce a clear Go/No-Go decision table for `release-please` and `auto-merge`.
- Create `docs/skill-hardening-guide.md` defining the requirements for "agent-friendly" skills (deterministic rules, checklists, decision tables).
### Out
- Refactoring `flutter-personal-standards` or other skills (deferred to future changes).
- Changing underlying implementation scripts.

## Approach
1. **Spec**: Draft `docs/skill-hardening-guide.md`.
2. **Refactor**: Update `dev-skills/repo-bootstrap/SKILL.md` with the new decision table.
3. **Verify**: Ensure the proposed changes align with the repository's weak-agent friendly philosophy defined in `README.md`.

## Rollback / Risks
- **Rollback**: Simple revert of commits.
- **Risk**: Low. Only markdown documentation changes.

## Estimated Effort
- Small: < 2 hours of work.
