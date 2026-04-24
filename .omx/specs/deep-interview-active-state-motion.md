# Deep Interview Spec: Active State Motion

## Metadata

- Profile: `standard`
- Rounds: `5`
- Final ambiguity: `0.15`
- Threshold: `0.20`
- Context type: `brownfield`
- Context snapshot: `.omx/context/active-state-motion-20260424T070505Z.md`
- Transcript: `.omx/interviews/active-state-motion-20260424T081015Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | --- |
| Intent | 0.84 |
| Outcome | 0.88 |
| Scope | 0.86 |
| Constraints | 0.92 |
| Success | 0.86 |
| Context | 0.96 |

## Intent

Make the NotchPet `active` state feel lively and premium without reading like the notch retracts into a smaller downward capsule. The active state should express motion around the notch while preserving the user's mental model that the physical notch center is not usable presentation space.

## Desired Outcome

`active` should read as a light, elegant, Dynamic-Island-like activity state:

- the visible activity space lives on the left and right sides of the notch
- the pet may appear, peek, jump, run briefly, and switch sides
- the pet must not be visibly presented in the notch center
- transitions and motion should feel polished and iOS-like rather than abrupt or merely utilitarian

## In Scope

- Refine `active` chrome so it no longer reads as a downward-expanded narrow island
- Preserve side-based activity space rather than center-filled presentation
- Use a lightweight lively action set:
  - peek
  - jump
  - short run
  - side switching
- Allow hidden transition treatment between left and right sides when crossing the notch
- Choose animation timing/choreography that feels elegant and Dynamic-Island-like
- Use `vibe-notch` as a directional visual-motion reference

## Out-of-Scope / Non-goals

- No information panelization in `active`
- No dense textual or multi-item informational content in `active`
- No requirement to show any information in `active` right now
- No overly complex multi-phase animation choreography in this iteration
- No visible pet traversal through the physical notch center
- No behavior that makes `active` read like `expanded`

## Decision Boundaries

OMX may decide without further confirmation:

- the exact width, height, and radii of the left/right active stage geometry
- whether side switching is expressed as hidden traversal, exit/re-entry, or another equivalent masked transition
- the exact ordering, tempo, and easing of the lightweight active motion sequence
- how strongly to borrow motion language from `vibe-notch`, provided the result remains original to NotchPet's pet behavior

OMX may not decide without further confirmation:

- to add information-panel behavior to `active`
- to surface multiple icons or dense information in `active`
- to make the pet visibly traverse the notch center
- to introduce highly complex, showy, multi-step animation systems that exceed the current incremental scope

## Constraints

- Brownfield SwiftUI/AppKit notch overlay app
- `expanded` remains the information-bearing state
- `active` should remain visually and behaviorally distinct from `expanded`
- The animation should feel elegant, with an iOS Dynamic Island sensibility
- `vibe-notch` is a user-approved direction reference for motion quality and notch expansion language

Reference:
- https://github.com/farouqaldori/vibe-notch

## Testable Acceptance Criteria

1. `active` no longer reads as the side chrome retracting into a smaller downward island.
2. `active` visibly uses left/right activity space rather than center-filled content presentation.
3. The pet is never visibly rendered in the physical notch center during `active`.
4. `active` remains clearly non-informational; no panel-like content is shown.
5. `active` motion uses a lightweight lively set such as peek, jump, short run, or side switching, without requiring all motions at once.
6. Side switching, if present, is hidden, masked, or otherwise represented without showing the pet in the notch center.
7. The motion feels smooth and elegant rather than abrupt, noisy, or over-choreographed.
8. `active` still reads as a lighter state than `expanded`.

## Assumptions Exposed + Resolutions

- Assumption: making `active` more dynamic might imply showing more information.
  Resolution: rejected. `active` is explicitly not an information state.

- Assumption: richer animation would require a complex choreography pass immediately.
  Resolution: rejected for this iteration. Motion should improve incrementally.

- Assumption: OMX would need approval for exact motion and geometry choices.
  Resolution: relaxed. OMX may choose those implementation details as long as the result stays elegant and within the declared non-goals.

## Pressure-Pass Findings

The decisive pressure pass asked what `active` most explicitly should not become. That surfaced the strongest latent boundary: the user does not want `active` to drift toward an information panel. This sharpened both scope and implementation freedom.

## Brownfield Evidence vs Inference

Evidence:

- The current active treatment uses a narrower island shape below the notch rather than side-oriented activity space.
- Existing motion content already suggests an active pet, but the container shape undermines that read.
- Broader three-state planning artifacts already exist under `.omx/plans/`.

Inference:

- The main remaining implementation challenge is shape-motion alignment, not state-model redesign.
- The best next step is execution against this narrower active-state brief rather than reopening planning from scratch.

## Technical Context Findings

Likely touchpoints:

- `NotchPet/NotchViewModel.swift`
- `NotchPet/PetView.swift`
- `NotchPet/NotchWindowController.swift`

Supporting context:

- `.omx/plans/prd-notch-overlay-states.md`
- `.omx/plans/test-spec-notch-overlay-states.md`
- `.omx/context/active-state-motion-20260424T070505Z.md`

## Condensed Transcript

- `active` should use left/right activity areas, not center-filled content
- the pet must not be visible in the notch center
- acceptable lightweight actions: peek, jump, short run, side switching
- `active` must not become informational
- complex choreography is out for now
- OMX may decide exact motion/geometry details
- motion quality should feel elegant and Dynamic-Island-like
- `vibe-notch` is a direction reference

## Handoff

Recommended next step: `ralph` or direct implementation against this spec, because the broader planning artifacts already exist and the remaining ambiguity for `active` is now below threshold.
