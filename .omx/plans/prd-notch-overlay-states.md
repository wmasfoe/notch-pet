# RALPLAN-DR Short Plan: Notch Overlay State Refactor

## Requirements Summary

- Refactor the overlay to support exactly three user-facing states: `idle`, `active`, `expanded`.
- `idle` must visually attach the pet to the notch edge with little or no visible black capsule.
- For this iteration, “little or no visible black capsule” means the `idle` chrome must not visibly extend past the physical notch by more than 8 px per side during static inspection, aside from the pet artwork itself.
- `active` may grow slightly beyond the physical notch, but must remain one unified Dynamic-Island-like silhouette, never detached left/right blocks.
- For this iteration, “slightly beyond the physical notch” means `active` chrome may extend beyond `deviceNotchRect.width` by at most 24 px per side while remaining one contiguous shape.
- `expanded` may show extra information, but must open only from manual click on the notch-pet.
- Hover may promote `idle -> active`.
- Hover may not trigger `expanded`.
- No automatic information panel popup.
- In this iteration, `idle` vs `active` must also be manually user-settable.
- Exclude Claude/CLI listener logic.

Grounding:
- Current state model is `closed/hovered/expanded`, with `closedSize.width` forced to at least `182`: [NotchViewModel.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewModel.swift:10), [NotchViewModel.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewModel.swift:39)
- Hover currently promotes any non-expanded state to `.hovered`: [NotchViewModel.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewModel.swift:92)
- Tap currently toggles `.expanded` off a shared state toggle: [NotchViewModel.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewModel.swift:107)
- `PetView` always paints a full black clipped panel and keeps a runway in non-expanded states: [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:27), [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:123), [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:195)
- Sleep logic is currently tied to `.closed`: [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:243)
- Full-width top overlay and pass-through hit-testing already exist: [NotchWindowController.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchWindowController.swift:16), [NotchViewController.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewController.swift:9)
- Unified island silhouette already exists in `NotchShape`: [NotchShape.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchShape.swift:8)
- Walking and sleeping cat frames already exist: [PixelPets.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PixelPets.swift:15), [PixelPets.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PixelPets.swift:74)

## Acceptance Criteria

1. `NotchStatus` exposes `idle`, `active`, and `expanded`, and no hover-only presentation state remains in the main user model.
2. In `idle`, the visible chrome width stays within `deviceNotchRect.width + 16` total tolerance and detached black side capsules are not rendered.
3. In `active`, the visible chrome width stays within `deviceNotchRect.width + 48` total tolerance and remains a single contiguous silhouette; no separate left/right stage blocks are visible.
4. Hover can transition `idle -> active`, but never `idle/active -> expanded`.
5. Clicking the notch-pet toggles `expanded` and collapsing from `expanded` returns to the prior non-expanded manual mode rather than a synthetic hover mode.
6. A manual control path exists in this iteration to set `idle` vs `active` without relying on hover.
7. No automatic info panel expansion occurs from hover, inactivity, launch animation, or timers.
8. Sleep/idle animation rules no longer depend on legacy `.closed` naming and remain coherent in `idle`.
9. Hit-testing remains constrained to the island interaction region and pass-through behavior outside that region is preserved.
10. Verification includes at minimum a build pass and state-transition coverage for the new state model.
11. The state machine defines explicit precedence between manual base mode, hover promotion, and `expanded`, so collapse/restore behavior is deterministic.
12. `idle` retains an invisible hover affordance or hit slop extending at least 12 px beyond the visible idle chrome on each horizontal side, without reintroducing a visible detached capsule.
13. The execution build gate is explicit: `swift build`, `swift test`, and `./build.sh` are all in scope and all must pass before the task is considered complete.

## RALPLAN-DR Summary

### Principles

1. Preserve one contiguous notch silhouette across all non-expanded states.
2. Split visual state from trigger source so hover can activate without owning the model.
3. Reuse existing overlay/window scaffolding and `NotchShape` before adding new infrastructure.
4. Make manual mode selection explicit in the view model instead of encoding it through timers alone.
5. Separate visible chrome from interactive hit area so minimal `idle` visuals do not break hover discoverability.

### Decision Drivers

1. Visual fidelity to a notch-attached or Dynamic-Island-like shape.
2. Predictable interaction rules: hover only for `idle -> active`, click only for `expanded`.
3. Minimal brownfield risk by refactoring around existing view-model and view seams.
4. Preserve reliable hover/click affordances even when `idle` has almost no visible chrome.

### Viable Options

#### Option A: Rename the existing three states in place and keep transient hover behavior inside `status`

Pros:
- Smallest diff in `NotchViewModel.swift`.
- Fastest path to replacing `closed/hovered/expanded` with new names.

Cons:
- Keeps trigger-source and visual-state coupled.
- Makes manual `idle` vs `active` persistence awkward because hover still impersonates a durable state.
- High risk of reintroducing automatic transitions and regressions around collapse logic.

#### Option B: Use durable display states plus a separate interaction/manual-mode layer

Pros:
- Matches the requested behavior cleanly: manual mode, hover promotion, click-only expansion.
- Lets `expanded` return to the correct prior base mode.
- Supports visual simplification in `PetView` without synthetic hover-state branches.

Cons:
- Slightly broader refactor across `NotchViewModel.swift` and `PetView.swift`.
- Requires updating boot/collapse logic and hit-test sizing to read from the new model.

### Recommendation

Choose Option B.

Reason:
- The current issues come from state conflation more than from missing drawing primitives. A durable base-mode model plus derived interaction state is the cleanest way to satisfy manual `idle/active`, hover promotion without auto-expansion, and click-only `expanded` while reusing the existing overlay controller and `NotchShape`.

### Exact State API Contract

The executor must implement an explicit contract equivalent to:

- `baseMode: idle | active`
- `isHoverPromoted: Bool`
- `isExpanded: Bool`

Derived render-state precedence:
1. if `isExpanded == true`, render `expanded`
2. else if `baseMode == active`, render `active`
3. else if `baseMode == idle && isHoverPromoted == true`, render `active`
4. else render `idle`

Behavioral rules:
- Hover may set `isHoverPromoted = true` only while `baseMode == idle`
- Hover exit must clear `isHoverPromoted`
- Click toggles `isExpanded`
- Collapsing `expanded` must restore the non-expanded render state implied by `baseMode` plus current hover condition
- Timers/inactivity may affect pet animation, but may not set `isExpanded = true`

## Implementation Steps

1. Extract a synchronous, testable transition layer in [NotchViewModel.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/NotchViewModel.swift:10).
   - Replace `closed/hovered/expanded` with a state model that explicitly separates:
     - durable base mode (`idle` or `active`)
     - transient hover promotion
     - expanded presentation
   - Define explicit precedence rules for render state and restore behavior:
     - manual base mode is authoritative for non-expanded fallback
     - hover may temporarily promote `idle -> active`
     - click alone may toggle `expanded`
   - Rework `currentSize`, padding, hit-test rect, and collapse logic to derive from that state machine.
   - Isolate transition decisions into synchronous helpers or pure functions so unit tests do not depend on `DispatchWorkItem` timing.
   - Ensure `toggleExpanded()` restores the prior non-expanded manual mode.

2. Add transition tests before the main UI refactor.
   - Add a new `NotchPetTests` target because the repo currently exposes no tests in `Package.swift`: [Package.swift](/Users/gztd-03-01473/code/mac-notch-pet/Package.swift:1)
   - Cover hover promotion, click-only expansion, restore-from-expanded, and timer/inactivity non-goals against the new state model.
   - Use this layer to lock deterministic precedence before touching the silhouette-heavy SwiftUI rendering.
   - Include explicit assertions for the precedence contract above.

3. Redesign non-expanded rendering in [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:19).
   - Remove the assumption that every state paints a full black panel background.
   - Split island chrome so `idle` uses minimal visible black mass and `active` uses one contiguous island silhouette.
   - Replace the always-on runway in `petStage` with state-specific staging that does not create detached left/right blocks.
   - Keep `NotchShape` as the primary unified outline for `active` and `expanded`.
   - Keep the visual silhouette separate from the hoverable hit area so `idle` can stay visually light while still being discoverable.

4. Rebind behaviors and animations in [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:50).
   - Keep hover restricted to `idle -> active`.
   - Keep click as the only entry to `expanded`.
   - Update sleep/wake, movement speed, and frame-selection logic so legacy `.closed` assumptions move to `idle`.
   - Preserve use of existing walking/sleeping frames from [PixelPets.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PixelPets.swift:15).

5. Add a manual control path for `idle` vs `active`.
   - Preferred narrow scope: add a small in-island manual toggle only inside `expanded` in [PetView.swift](/Users/gztd-03-01473/code/mac-notch-pet/NotchPet/PetView.swift:77), which updates the durable base mode in `NotchViewModel`.
   - This satisfies the iteration requirement without adding menu-bar settings or new app surfaces.

6. Finish with regression coverage and verification plumbing.
   - Extend the earlier tests to cover final rendering/state integration where practical.
   - Update [build.sh](/Users/gztd-03-01473/code/mac-notch-pet/build.sh:1) so it includes any newly required Swift files and remains a supported build surface for this task.
   - Verify all three build surfaces: `swift test`, `swift build`, and `./build.sh`.

Scope estimate:
- Primary code files: 4 to 5
- Expected touchpoints: `NotchViewModel.swift`, `PetView.swift`, `NotchShape.swift` if silhouette tuning is needed, `Package.swift`, plus a new tests file/directory
- Complexity: Medium

## Risks and Mitigations

- Risk: State regression from replacing a simple enum with base-mode plus transient interaction logic.
  - Mitigation: Add explicit transition tests before the main visual refactor.

- Risk: Minimal `idle` chrome makes the hover target too hard to discover or too small to hit reliably.
  - Mitigation: Preserve an invisible but bounded hit area separate from the visible silhouette, and verify it manually.

- Risk: Idle rendering still reads as a detached capsule because the pet stage keeps its own runway.
  - Mitigation: Treat the stage background as state-specific chrome, not as a permanent subview.

- Risk: Expanded collapse returns to the wrong non-expanded state.
  - Mitigation: Store prior manual/base mode explicitly in the view model and test both `idle` and `active` restore paths.

- Risk: Manual mode control adds visual clutter.
  - Mitigation: Keep the control inside `expanded` only for this iteration.

- Risk: Build verification is under-specified because the repo currently has no tests and `build.sh` uses explicit file lists.
  - Mitigation: Add a package test target, bring `build.sh` into scope explicitly, and require `swift test`, `swift build`, and `./build.sh` to pass.

## Verification Steps

1. Add unit coverage for:
   - default base mode
   - hover promotes `idle -> active`
   - hover does not expand
   - click toggles `expanded`
   - collapse from `expanded` restores prior manual mode
   - no automatic expanded transition from timers/inactivity
   - state-precedence rules between manual mode, hover promotion, and expanded

2. Run package tests:
   - `swift test`

3. Run app build verification:
   - `swift build`
   - `./build.sh`

4. Perform manual interaction verification on macOS:
   - hover over idle island
   - click to expand
   - click to collapse
   - set manual `idle`
   - set manual `active`
   - confirm `idle` visible chrome does not exceed physical notch width by more than 8 px per side
   - confirm `active` visible chrome does not exceed physical notch width by more than 24 px per side
   - confirm no detached left/right blocks in non-expanded states
   - confirm no hover-driven info-panel expansion

## ADR

### Decision

Adopt a durable three-state display model (`idle`, `active`, `expanded`) with a separate manual/base-mode source so hover can temporarily promote activity and click alone controls information expansion.

### Drivers

- The current `closed/hovered/expanded` model conflates display state and interaction source.
- The user-approved behavior requires manual `idle/active` control plus click-only `expanded`.
- The existing code already provides the right overlay shell and unified silhouette primitive.

### Alternatives Considered

- Keep a hover-owned `active` state in the main enum and infer manual mode indirectly.
  - Rejected because it makes restore-from-expanded and no-auto-popup behavior fragile.
- Add separate left/right notch attachments for the pet in `active`.
  - Rejected because it violates the unified-island requirement.

### Why Chosen

- It is the narrowest design that satisfies all requested interaction rules without replacing the window/controller architecture.

### Consequences

- `NotchViewModel` becomes slightly richer, but interaction semantics become testable instead of implicit.
- `PetView` must stop treating the black panel and runway as universal chrome.
- Verification burden shifts toward transition tests and hit-area validation, which is appropriate for this refactor.

### Follow-ups

- If this iteration lands cleanly, consider extracting island metrics/chrome into a dedicated presenter or style type.
- If manual mode needs persistence across launches later, add storage only after the in-memory behavior is validated.

## Available-Agent-Types Roster

Relevant follow-up agent types for this repo:
- `executor`: implement the state-model and SwiftUI/AppKit refactor
- `architect`: review state-model boundaries and ensure the silhouette/interaction split is coherent
- `test-engineer`: add transition coverage and verify testability of the new model
- `verifier`: run completion checks and confirm evidence matches claims
- `explore`: fast repo lookup for build/test or file-ownership questions during execution
- `designer`: optional review of notch/island interaction clarity if the implementation needs visual tradeoff input

## Follow-up Staffing Guidance

### `$ralph`

- Recommended lanes:
  - `executor` at `high`: own `NotchViewModel.swift` and `PetView.swift`
  - `test-engineer` at `medium`: own `Package.swift` test-target setup and transition tests
  - `architect` at `medium`: perform final design/behavior sign-off after evidence is collected
- Why:
  - This is a medium brownfield refactor with one dominant implementation lane and one independent evidence lane.

### `$team`

- Recommended headcount: 3
- Lane 1: `executor` at `high`
  - Ownership: `NotchViewModel.swift`, `PetView.swift`, optional `NotchShape.swift`
- Lane 2: `test-engineer` at `medium`
  - Ownership: `Package.swift`, `NotchPetTests/**`, verification commands
- Lane 3: `verifier` or `architect` at `medium`
  - Ownership: evidence review, manual interaction checklist, build/test confirmation
- If `verifier` is unavailable in team runtime, use `architect` as the closest rostered substitute for final sign-off.

## `$team` / `omx team` Launch Hints

Suggested launch:

```bash
omx team 3:executor "Implement the approved notch overlay state refactor plan: durable idle/active/expanded model, unified island rendering, click-only expanded, manual idle/active control in expanded, add transition tests and verification evidence."
```

Operational staffing note:
- Use the shared task list to split delivery, regression coverage, and final evidence review into separate lanes immediately after startup.

Concrete team verification path:
1. Delivery lane finishes the state-model and `PetView` refactor.
2. Regression lane adds tests and runs `swift test`.
3. Verification lane runs `swift build` and the manual interaction checklist.
4. Architect/verifier lane compares the final behavior against the acceptance criteria and confirms:
   - no detached left/right blocks
   - hover only promotes to `active`
   - click alone controls `expanded`
   - manual `idle/active` control exists
   - `idle` remains hoverable without restoring a visible detached capsule
5. Shut down team mode only after task counts are terminal and evidence is recorded.

## Applied Improvements

- Added an explicit state-precedence requirement so manual mode, hover promotion, and expanded restore rules are deterministic.
- Front-loaded state-transition testing before the main SwiftUI silhouette refactor.
- Added a separate hit-area / visible-chrome constraint so minimal `idle` visuals do not break discoverability.
- Converted visual acceptance and build verification from qualitative guidance into explicit thresholds and required commands.
