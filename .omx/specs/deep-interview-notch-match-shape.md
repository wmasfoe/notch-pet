# Deep Interview Spec: Notch Match Shape

## Metadata

- Profile: `standard`
- Rounds: `4`
- Final ambiguity: `0.14`
- Threshold: `0.20`
- Context type: `brownfield`
- Context snapshot: `.omx/context/notch-match-shape-20260423T111700Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | --- |
| Intent | 0.90 |
| Outcome | 0.90 |
| Scope | 0.92 |
| Constraints | 0.93 |
| Success | 0.84 |
| Context | 0.85 |

## Intent

The overlay should stop reading as two detached black blocks and instead feel visually anchored to the MacBook notch with state-appropriate behavior.

## Desired Outcome

Three distinct states:

1. `idle`
Minimal and quiet. The pet stays attached to the notch edge with little or no obvious black capsule.

2. `active`
May be slightly wider than the physical notch, but must read as one unified Dynamic-Island-like shape, never as left/right detached black blocks. The pet may move inside this island.

3. `expanded`
Shows additional information, but only after a user manually clicks the notch-pet.

## In Scope

- Rework idle, active, and expanded into separate visual/interaction states
- Make active read as one unified island
- Make idle visually light and notch-edge anchored
- Allow hover to promote `idle -> active`
- Keep expanded behind click only
- Support a simple user-controlled active/idle setting for the current iteration

## Out-of-Scope / Non-goals

- No hover-driven auto-entry into `expanded`
- No automatic information panel popup
- No Claude Code / CLI listener logic
- No requirement yet for richer automatic active/idle inference beyond the allowed hover activation

## Decision Boundaries

OMX may decide:

- Exact geometry values, radii, padding, animation timing, and the concrete visual treatment for the unified island
- The concrete control used for manual active/idle selection in this phase

OMX may not decide:

- Any behavior that auto-opens `expanded`
- Any behavior that auto-opens the information panel
- Any redesign that collapses idle and active into one shared silhouette

## Constraints

- Brownfield SwiftUI/AppKit overlay app
- Visual fidelity to the notch region matters more than preserving the placeholder layout
- The result should align directionally with `vibe-notch` interaction language and `mac-pet` pet behavior

## Testable Acceptance Criteria

- In `active`, the overlay reads as a single unified island rather than two detached blocks
- In `idle`, the pet can remain attached to the notch edge without a prominent black capsule
- Hovering while idle can promote the pet into `active`
- Hovering never opens `expanded`
- `expanded` can only be entered by manual click on the notch-pet
- Information UI does not auto-popup
- A user can manually choose active vs idle in the current phase

## Assumptions Exposed + Resolutions

- Assumption: state changes should remain fully manual
Resolution: refined; active/idle selection is manually controllable, but hover may still activate the pet visually

- Assumption: hover might reasonably open the expanded view
Resolution: rejected; expanded is click-only

## Pressure-pass Findings

The key ambiguity was whether hover should have any state effect. The answer narrowed it precisely:
- hover may activate
- hover may not expand

## Brownfield Evidence vs Inference

Evidence:
- `NotchViewModel.closedSize` is forced to a minimum width that can exceed the physical notch
- `PetView` currently paints a full black clipped panel, causing the detached-block look

Inference:
- `idle` and `active` should render through different silhouette rules rather than one shared closed panel

## Technical Context Findings

- Likely touchpoints:
  - `NotchPet/NotchViewModel.swift`
  - `NotchPet/PetView.swift`
  - `NotchPet/NotchShape.swift`
  - `NotchPet/NotchWindowController.swift`

## Condensed Transcript

- `close = B`, `idle = C`
- `active` should be one unified island, slightly wider than the real notch if needed
- `idle` should minimize the black base and let the pet sit at the notch edge
- `expanded` is click-only
- hover may activate the pet
- hover may not expand the panel
- no automatic information popup
