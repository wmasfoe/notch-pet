# RALPLAN-DR Short Plan: Active State Motion Refinement

## Scope Override

This plan supersedes only the `active`-state visual/motion slice of `.omx/plans/prd-notch-overlay-states.md`.

It does **not** reopen the broader state-model refactor, because the live repo already contains:

- `NotchStatus.idle / active / expanded`
- `NotchStateModel` with `baseMode`, `isHoverPromoted`, and `isExpanded`
- transition tests in `NotchPetTests/NotchStateModelTests.swift`

The remaining planning target is narrower: align the `active` chrome and motion with the clarified brief from `.omx/specs/deep-interview-active-state-motion.md`.

## Requirements Summary

- Keep the existing three-state state model intact unless a minimal supporting adjustment is required.
- Refine only the `active` state so it no longer reads as a narrow downward island under the notch.
- `active` should use left/right activity space around the notch rather than center-filled presentation.
- The pet must never be visibly shown in the physical notch center during `active`.
- The notch center may remain hover/tap-active for continuity, but it should stay visually quiet and never display pet content in `active`.
- `active` must remain non-informational. No panel-like content should appear there.
- Animation should feel elegant and Dynamic-Island-like, but the implementation should stay incremental rather than highly choreographed.
- `expanded` remains the place for information and manual mode switching.
- No new dependencies.

Grounding:
- `NotchViewModel.swift` already exposes the durable state model and active sizing hooks.
- `PetView.swift` still renders `active` through `islandChrome`, which creates the downward one-piece read that conflicts with the clarified spec.
- `PetView.swift` already contains reusable sprite logic (`patrolStage`, bounce, frame timing) that can be adapted instead of replaced.
- `build.sh`, `Package.swift`, and `NotchPetTests/NotchStateModelTests.swift` are already in scope as verification surfaces.

## Acceptance Criteria

1. `active` no longer reads as the side chrome retracting into a smaller downward island below the notch.
2. `active` uses visible left/right activity areas and does not present pet content in the notch center.
3. Any left/right traversal hides the center crossing via masking, exit/re-entry, or equivalent treatment.
4. `active` shows no information panel, no text payload, and no dense UI content.
5. `active` remains visually lighter than `expanded`, and materially narrower than the expanded panel while still providing credible left/right activity bays.
6. The notch center stays visually quiet and remains hover/tap-active by default; if implementation changes that behavior, it must be treated as an explicit exception, documented in the final report, and manually re-verified.
7. Motion in `active` uses a lightweight lively set such as peek, jump, short run, or side switching, without requiring all motions simultaneously.
8. Existing `idle -> active` hover promotion and click-only `expanded` behavior continue to work.
9. Existing state-model tests still pass, and any new active layout/motion helper logic receives deterministic unit coverage.
10. `swift test`, `swift build`, and `./build.sh` all pass.

## RALPLAN-DR Summary

### Principles

1. Preserve the already-landed state model; refine presentation, not architecture, unless a narrow seam is missing.
2. Keep the notch center visually sacred in `active`: activity happens beside it, not through it.
3. Reuse existing sprite timing and window scaffolding before adding new layers.
4. Favor one clean motion language over many competing micro-animations.
5. Keep the diff reversible by isolating active-specific geometry and motion decisions.
6. Keep active-stage rendering policy in `PetView`; allow `NotchViewModel` to own only coarse container metrics needed for window sizing and hit-area math.

### Decision Drivers

1. Alignment with the clarified `active-state-motion` spec.
2. Minimal diff against the already-landed three-state model and tests.
3. Visual quality: elegant, Dynamic-Island-like motion without information-panel drift.
4. Preserve interaction continuity unless a narrower hit model is proven necessary.

### Viable Options

#### Option A: Keep a single contiguous `active` island and only tune timing/height

Pros:
- Smallest geometry diff.
- Reuses the current `islandChrome` path almost unchanged.

Cons:
- Conflicts with the clarified requirement that activity should read as left/right side space.
- Keeps the current downward-island read that triggered the follow-up interview.

#### Option B: Add active-specific side-stage chrome while preserving the existing state model

Pros:
- Matches the clarified brief directly.
- Limits changes to `PetView` rendering and a small amount of sizing/metrics logic.
- Keeps `expanded` and the base interaction model mostly untouched.

Cons:
- Requires a new active-specific chrome composition instead of reusing the current island shape wholesale.
- Needs careful masking so side-switching reads cleanly.

#### Option C: Reopen the full non-expanded chrome system and unify idle/active/expanded rendering again

Pros:
- Could produce a more uniform long-term rendering architecture.

Cons:
- Over-scoped for the current clarified task.
- Risks destabilizing already-landed state-model work and tests.
- Reintroduces planning churn the interview just resolved.

Invalidation rationale:
- Option A is too weak against the clarified brief.
- Option C is too broad for the remaining gap.

### Recommended Approach

Choose **Option B** with a hybrid-silhouette synthesis.

Keep the current state model and test surface. Replace only the `active` visual treatment with an active-specific side-stage presentation that:

- visually anchors to the notch edges
- leaves the notch center free of visible pet content while allowing a restrained connected top bridge if needed for morph continuity
- reuses current sprite timing primitives where possible
- introduces only narrow helper abstractions if needed for active-stage layout or masked side-switching
- keeps the notch center hover/tap-active by default, with visual quietness handled by rendering rather than hit-test surgery

## Implementation Steps

1. Make `PetView.swift` the primary change surface.
   - Keep `NotchStatus` / `NotchStateModel` behavior unchanged.
   - Preserve `NotchViewModel.swift` ownership of only coarse container sizing needed for window-frame math.
   - Change `visibleChromeSize` for `active` only if the new side-bay composition cannot be supported inside the current coarse container.

2. Split `active` rendering out of the shared `islandChrome` path in `PetView.swift`.
   - Preserve `expanded` as the information-bearing full island.
   - Keep `idle` as-is unless a tiny alignment tweak is required to support the new `active` transition.
   - Introduce an `activeChrome` composition that renders left/right stage space and keeps the center visually quiet.
   - Prefer a hybrid silhouette: restrained connected top bridge plus masked left/right activity bays, rather than two fully detached stage blocks.

3. Extract deterministic active layout/motion helpers before wiring the final animation.
   - Create a pure helper for active-stage layout and/or motion phase selection so center masking and side-switch behavior are unit-testable.
   - Keep time-driven SwiftUI rendering thin and fed by those helpers.

4. Adapt motion logic to the side-stage layout.
   - Reuse `patrolStage`, frame timing, and bounce primitives where possible.
   - Add a narrow active-motion helper that supports peek/jump/short-run/side-switching without visible center traversal.
   - Prefer masked crossing or exit/re-entry over a continuous center-visible run.

5. Keep center interaction explicit and stable.
   - Treat the notch center as visually quiet but still hover/tap-active by default.
   - Avoid changing `NotchViewController` hit-testing unless implementation evidence shows the current interaction continuity is incompatible with the refined active chrome.
   - If hit behavior changes anyway, treat that as an exception path that must be documented and explicitly re-verified by manual interaction checks.

6. Keep transitions elegant but incremental.
   - Reuse the existing spring-based state transition shell where it still reads well.
   - If needed, add only small active-specific content reveal/motion timing changes instead of a large choreography system.

7. Extend verification surfaces only where the refinement changes behavior.
   - Keep existing `NotchStateModelTests` intact.
   - Add focused tests for extracted active-motion/layout helpers that enforce the no-center-visible rule and side-switch policy.
   - Keep manual verification explicit for the final visual read.

## Risks and Mitigations

- Risk: The new `active` chrome drifts too close to the idle wing treatment and no longer reads as active.
  - Mitigation: Differentiate `active` via motion energy, slightly stronger stage presence, and distinct timing rather than heavier information UI.

- Risk: Side switching looks teleporty or awkward.
  - Mitigation: Use masked center crossing or explicit exit/re-entry, and keep the move short and intentional.

- Risk: The active silhouette becomes too disconnected and reads like animated idle wings.
  - Mitigation: Preserve a restrained connected top bridge or equivalent continuity cue so `active` still reads as a notch-centric state.

- Risk: Refactoring `PetView` introduces accidental regressions in `expanded`.
  - Mitigation: Keep `expandedContent` and `islandChrome` ownership intact; isolate new active-specific rendering in a separate branch/helper.

- Risk: Verification becomes too visual-only.
  - Mitigation: Preserve build/test gates and require extracted deterministic helper logic for stage layout or phase selection.

## Verification Steps

1. Run automated verification:
   - `swift test`
   - `swift build`
   - `./build.sh`

2. Manual verification on macOS:
   - confirm `idle -> active` still triggers on hover
   - confirm click still opens `expanded`
   - confirm `active` no longer reads as a downward capsule
   - confirm `active` remains visually lighter and materially narrower than `expanded`
   - confirm the pet never becomes visible in the notch center
   - confirm the notch center still participates in hover/tap activation unless implementation evidence required a deliberate interaction change
   - confirm `active` shows no information panel content
   - confirm side-switching, if present, feels elegant rather than abrupt

## ADR

### Decision

Refine only the `active` state presentation/motion layer while preserving the already-landed three-state model and existing transition behavior.

### Drivers

- The clarified brief narrowed the remaining problem to `active` chrome/motion alignment.
- The live repo already contains the intended state model and tests.
- Reopening the larger state-model refactor would create unnecessary churn.

### Alternatives Considered

- Tune the current single-piece active island only.
  - Rejected because it does not satisfy the side-activity-space requirement.
- Rework the full non-expanded rendering system again.
  - Rejected because it is broader than the remaining gap.

### Why Chosen

- This is the smallest plan that matches the clarified interview outcome and the current live codebase at the same time.

### Consequences

- `PetView.swift` becomes the main change surface.
- `NotchViewModel.swift` should change only for coarse container sizing or support data, not active-stage rendering policy.
- Visual verification remains important because the change is presentation-heavy.

### Follow-ups

- If the active side-stage model lands cleanly, later work can revisit cross-state morph polish and expanded information layout separately.

## Available-Agent-Types Roster

- `executor`: implement the active chrome/motion refinement
- `architect`: review shape/motion boundaries and notch-center masking strategy
- `test-engineer`: validate helper extraction and regression coverage
- `verifier`: run build/test/manual evidence checks
- `designer`: optional visual tradeoff review if active readability is still ambiguous
- `explore`: quick lookup support during execution

## Follow-up Staffing Guidance

### `$ralph`

- `executor` at `high`: own `PetView.swift` and any supporting `NotchViewModel.swift` adjustments
- `test-engineer` at `medium`: own targeted helper tests plus regression confirmation
- `verifier` at `medium`: own final build/test/manual evidence pass

Launch hint:
- `$ralph .omx/plans/prd-active-state-motion-refinement.md`

### `$team`

- Lane 1 `executor` at `high`: active chrome/motion rendering in `PetView.swift`
- Lane 2 `test-engineer` at `medium`: focused helper coverage and build/test verification
- Lane 3 `architect` at `medium`: review notch-center masking and transition quality after lane 1 lands

Launch hint:
- `$team .omx/plans/prd-active-state-motion-refinement.md`

## Team Verification Path

1. Implementation lane lands active-specific rendering changes.
2. Test lane confirms `swift test`, `swift build`, and `./build.sh`.
3. Architect/verifier lane checks the result against the active-state spec and manual visual criteria.
4. If visual read still conflicts with the spec, iterate only on the active presentation layer.
