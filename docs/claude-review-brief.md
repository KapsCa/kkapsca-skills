# Claude Review Brief — KkapsCa Skills Repository

## Project Goal

This repository is a curated set of **skills for AI agents**.

The core objective is not just to document workflows, but to make them **highly executable by agents**, including agents with weaker reasoning capabilities.

That means skills in this repo should optimize for:

- low ambiguity,
- explicit triggers,
- deterministic rules,
- decision tables,
- pre-flight checklists,
- minimal fluff,
- high consistency of execution.

The repository is effectively a **project kickstart + agent skills system**.

---

## Core Design Philosophy

The main philosophy of this repo is:

1. **Think before building**
   - Early pipeline skills help shape ideas before implementation.

2. **Bootstrap repos correctly**
   - New projects should start with clean Git/GitHub discipline.

3. **Optimize for agent execution quality**
   - A skill is considered good only if even a weaker agent can follow it and produce acceptable output.

4. **Avoid duplicated generic knowledge**
   - If official skills already cover a domain well, project skills should add personal standards, routing, or project-specific constraints instead of repeating generic tutorials.

---

## Current Pipeline

Recommended flow in this repo:

```text
Idea → brainstorm → product-discovery → tech-feasibility → repo-bootstrap → Development Skill
```

### Early-stage skills

- `brainstorm`
- `product-discovery`
- `tech-feasibility`

### Development skills

- `repo-bootstrap`
- `flutter-personal-standards`

### Internal / company-specific skills

- `ananta-standards`

---

## Important Skills

### 1. `repo-bootstrap`

Purpose:
- standardize new repos,
- enforce PR-based workflow,
- require `release-please`,
- define branch rules,
- require functional validation checks before auto-merge.

Important conventions:
- default branch should be `main`
- no direct push to `main`
- every repo should use PRs
- `release-please` is mandatory for new repos
- auto-merge is allowed only after:
  - PR validation,
  - required checks,
  - functional stack-specific validation
- review automation is desirable, but checks are mandatory

This skill was recently hardened to be more **weak-agent friendly** by adding:
- pre-flight checklist,
- deterministic stack → test command table,
- go/no-go conditions for auto-merge.

### 2. `flutter-personal-standards`

Purpose:
- provide personal architectural guidance for Flutter,
- route specific problems to official Flutter skills,
- avoid forcing GetX as a default.

Important conventions:
- simple first,
- architecture proportional to project size,
- explicit thresholds for complexity,
- explicit decision table for state management,
- route to official Flutter skills when the problem is specialized.

This skill replaced an older generic `flutter` skill that overlapped too much with official Flutter skills.

### 3. `ananta-standards`

Purpose:
- define project-specific standards for **Ananta**,
- assume Flutter + GetX as project context,
- impose bindings, feature structure, and clear layer responsibilities.

Important conventions:
- `Get.find()` should not be scattered everywhere
- dependencies should enter through `Bindings`
- UI should not hold business logic
- navigation should use named routes and `GetPage`
- feature/module structure should be explicit

This skill is intentionally internal to the company and should not be treated as generic Flutter guidance.

### 4. `skill-creator`

Purpose:
- help create or improve skills.

Recent direction:
- moved toward a more deterministic design,
- stronger intent capture,
- less fluff,
- clearer state → action flow,
- better fit for this repository's “weak-agent friendly” philosophy.

---

## Git/GitHub Standards Already Introduced

The repository has been evolving toward a stronger GitHub workflow standard:

- issue-first PR workflow
- PR templates
- issue templates
- PR validation workflow
- ShellCheck workflow
- `release-please`
- `main` as default branch

There is also a preference that GitHub publishing actions (push, PR creation, issue creation, release-related publishing) should be delegated through a cheap/free specialized subagent.

---

## Review Focus Requested

Please review this repository with special focus on these questions:

1. Are the skills sufficiently optimized for **weaker agents**?
2. Where is ambiguity still too high?
3. Which parts are still too verbose relative to execution value?
4. Which skills should be further converted into:
   - decision tables,
   - hard checklists,
   - deterministic state/action flows?
5. Are any skills still duplicating knowledge that should instead be delegated to official skills?
6. Does `repo-bootstrap` look like a strong transversal standard for all new projects?
7. Are `flutter-personal-standards` and `ananta-standards` clearly separated in responsibility?

---

## What Not to Optimize For

Do **not** optimize for:

- beautiful prose,
- abstract architectural essays,
- instructions that assume strong inference,
- generic framework theory that already exists elsewhere.

Optimize for:

- actionability,
- consistency,
- clarity,
- low ambiguity,
- robust execution by AI agents.
