---
name: think
description: Invoke before writing any code for a new feature, design, or architecture decision. Turns rough ideas into approved plans with validated structure. Not for bug fixes or small edits.
metadata:
  version: "3.5.0"
---

# Think: Design and Validate Before You Build

Prefix your first line with 🥷 inline, not as its own paragraph.


Turn a rough idea into an approved plan. No code, no scaffolding, no pseudo-code until the user approves.

Give opinions directly. Take a position and state what evidence would change it. Avoid "That's interesting," "There are many ways to think about this," "You might want to consider."

## Before Reading Any Code

- Confirm the working path: `pwd` or `git rev-parse --show-toplevel`. Never assume `~/project` and `~/www/project` are the same.
- Check `docs/solutions/` if present for prior decisions on the same problem.
- Search for related issues and PRs on GitHub before proposing anything.

## Propose Approaches

Offer 2-3 options with tradeoffs and a recommendation. Always include one minimal option. For each option: one-sentence summary, effort, risk, and what existing code it builds on. For the recommendation: attack it first. What would make this fail? If the attack holds, deform the design and present the deformed version. If it shatters the approach entirely, discard it and tell the user why.

Get approval before proceeding. If the user rejects, ask specifically what did not work. Do not restart from scratch.

## Validate Before Handing Off

- More than 8 files or 1 new service? Acknowledge it explicitly.
- More than 3 components exchanging data? Draw an ASCII diagram. Look for cycles.
- Every meaningful test path listed: happy path, errors, edge cases.
- Can this be rolled back without touching data?
- Every API key, token, and third-party account the plan requires listed with one-line explanations. No credential requests mid-implementation.
- Every MCP server, external API, and third-party CLI the plan depends on verified as reachable before approval.

**Check the knowledge store first.** If the project has a `docs/solutions/` directory, search for prior decisions or related problems before proposing anything. If matches are found, read them before Phase 2. Prior solutions may contain decisions, tradeoffs, or known failure modes that eliminate false starts.

**Confirm the working path before touching the filesystem.** Before creating, moving, or writing files, verify the absolute path with `pwd` or `git rev-parse --show-toplevel`. Do not assume `~/project` and `~/www/project` are the same. If the user gives a relative or ambiguous path, ask once to confirm the full absolute path.

**State all dependencies before asking for credentials.** If the task requires API keys, tokens, or third-party accounts beyond what the user named, list every dependency with a one-line explanation of why it is needed, before asking for any of them. Do not surface credential requests mid-implementation.

**Verify external tool availability before starting.** If the task depends on MCP servers, external APIs, or third-party CLIs, list them upfront and confirm each is reachable before the first implementation step. A plan that requires a tool that is not loaded is not a plan.

**Check existing work on GitHub.** Before designing, search for related issues and PRs. If `gh` is not installed, install it first.

Challenge whether it is the right problem:
- What does the user actually want to happen? Not the feature described, the outcome they care about.
- What changes if nothing is built? Is there a cheaper path to the same result?
- What already exists in the codebase that covers part of this? Map sub-problems to existing code before proposing new code.
- Does this decision hold up in 12 months, or does it create drag?

## Scope Mode

Name the mode at the start:

| Mode | When | Posture |
|------|------|---------|
| **expand** | New feature, blank slate | Push scope up. Ask what would make this 10x better. |
| **shape** | Adding to existing | Hold the baseline, surface expansion options one at a time. |
| **hold** | Bug fix, tight constraints | Scope is locked. Make it correct. |
| **cut** | Plan that grew too large | Strip to the minimum that solves the real problem. |

## Phase 2: Propose Approaches

Offer 2 or 3 options with tradeoffs and a recommendation. For each: one-sentence summary, effort, risk, two strongest reasons for and against, what existing code it builds on. Always include one minimal option and one architecturally complete option.

When comparing, ask:
- Which decisions are hard to undo? Slow down on those.
- What would cause this to fail? Design away from that first.
- What are we explicitly not building?
- Would the same result hold with less: fewer fields, fewer states, fewer APIs?

Before presenting the recommendation: attack it. Ask yourself what would make this approach fail. If the attack holds, the approach deforms, and you should present the deformed version instead. If the attack shatters the approach entirely, discard it and tell the user why.

Get approval before proceeding. If the user rejects the design, do not start over from scratch. Ask what specifically did not work, incorporate those constraints, and re-enter Phase 2 with a narrowed option set.

## Phase 3: Validate the Architecture

Once a direction is approved, check structural correctness before implementation starts:

**Scope.** Grep for existing implementations of each sub-problem. Flag anything deferrable. More than 8 files or 2 new services? Acknowledge it explicitly.

**Dependencies and data flow.** If more than 3 components exchange data, draw an ASCII diagram. Look for cycles and hidden coupling. Trace the main path, then break it: nil input, empty collection, upstream timeout, partial failure.

**Test coverage.** List every meaningful path: happy path, error branches, edge cases. List gaps with file, assertion, test type. Any bug fix without a reproducing test is not done.

**Risk.** Name every component whose loss degrades the system. Can this be rolled back without touching data? Is the technology choice boring enough; non-standard choices accumulate maintenance cost.

If any section cannot be meaningfully evaluated from available information, say so explicitly: "Cannot assess X without seeing Y." Do not guess to fill the gap.

**No placeholders in approved plans.** Before the user approves, every step must be concrete. Forbidden patterns: TBD, TODO, "implement later", "similar to step N", "details to be determined", "as needed". A plan with placeholders is not a plan. It is a promise to plan later.

## Phase 4: Confidence Check

Before handing off to implementation, score confidence on three axes:

1. **Problem understood?** Can I state in one sentence what the user actually needs and why?
2. **Approach is the simplest that works?** Is there a cheaper path I have not considered?
3. **Unknowns are resolved or explicitly deferred?** No TBDs hidden in the plan.

If any axis is low: loop back. Low on (1) returns to Phase 1. Low on (2) returns to Phase 2. Low on (3) returns to Phase 3 and names each unresolved unknown explicitly.

If all three are solid: state the confidence assessment in 2-3 sentences at the end of the approved design summary, then stop. Do not proceed into implementation.

## Implementation Handoff

Think ends at approved design.

Once implementation starts, switch to `/drive` and follow that skill for Red-Green-Refactor execution.

When implementation is complete, use `/check` for final review and verification before merge.

## Gotchas

| What happened | Rule |
|---------------|------|
| Moved files to `~/project`, repo was at `~/www/project` | Run `pwd` before the first filesystem operation |
| Asked for API key after 3 implementation steps | List every dependency before handing off |
| User said "帮我做" and got 3 options | Stay in planning mode. Lead with the recommended option, and treat user acceptance as plan approval, not implementation approval. |
| Planned MCP workflow without checking if MCP was loaded | Verify tool availability before handing off, not mid-implementation |
| Rejected design restarted from scratch | Ask what specifically failed, re-enter with narrowed constraints |
| Built against wrong regional API (Shengwang vs Agora) | List all regional differences before writing integration code |
| Added FastAPI backend to a Next.js project | Never add a new language or runtime without explicit approval |
| User said "just do it" before approving the design | Treat it as approval of the last option presented. State which option was selected, then finish the plan. Do not implement inside `/think`. |

## Output

**Approved design summary:**
- **Building**: what this is (1 paragraph)
- **Not building**: explicit out-of-scope list
- **Approach**: chosen option with rationale
- **Key decisions**: 3-5 with reasoning
- **Unknowns**: only items that are explicitly deferred with a stated reason and a clear owner. Not vague gaps. If an unknown blocks a decision, loop back before approval.

After the user approves the design, stop. Implementation starts only when requested.
