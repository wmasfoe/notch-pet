# Cat Motion Reference Context

## Task Statement
Clarify the next visual/motion revision for NotchPet using the user's new cat sleep/walk references and the reported active-state shape problem.

## Desired Outcome
- Idle/sleeping cat should feel closer to the mac-pet sleep gif while keeping the existing `z` snore effect.
- Active cat should feel closer to the mac-pet walking gif.
- Active chrome should stop reading as three separate black blocks and instead feel more like a Dynamic Island.

## Stated Solution
- Sleep reference: `https://mac-pet.com/_next/static/media/cat-sleep.0~_q~u_1klsn4.gif`
- Active reference: `https://mac-pet.com/_next/static/media/cat-walking.17kz07gnhsw2u.gif`
- User-provided screenshot shows the current active shape as three black blocks rather than a unified Dynamic-Island-like form.

## Probable Intent Hypothesis
The user wants to preserve the directional work already done on state behavior, but refine two things together:
1. cat motion quality, so idle/active feel closer to a polished reference animation language
2. active chrome silhouette, so it reads as one Dynamic-Island-like system instead of three separate blocks

## Known Facts / Evidence
- Current `idleContent` already shows a sleeping cat plus a `SleepBubbleStack` with `z` snore effect.
- Current `active` path in `PetView` uses `ActiveChromeShape` plus left/right gloss lines and a dark center bridge.
- The user reports that the current active rendering still visually reads as three black blocks.
- Existing context/specs already established:
  - active must not become informational
  - pet must not be visibly shown in the physical notch center
  - center hover/tap continuity should remain unless deliberately changed

## Constraints
- Do not implement inside deep-interview mode.
- Ask one question per round.
- Keep active distinct from expanded.
- Preserve current preference: do not launch the built app unless necessary; if launched, close it before finishing.

## Unknowns / Open Questions
- Whether the user wants the active silhouette to become one continuous capsule/bridge visually, or just less visibly segmented.
- Whether the mac-pet references are about frame motion only, or also about cat pose/staging proportions.
- How much of the current left/right bay concept should be preserved versus visually merged.

## Decision-Boundary Unknowns
- Whether OMX may freely reinterpret the current active chrome into a more continuous island so long as the pet still never appears in the notch center.
- Whether the user wants exact fidelity to the mac-pet cat frames, or only directional resemblance.

## Likely Codebase Touchpoints
- `NotchPet/PetView.swift`
- `NotchPet/PixelPets.swift`
- `NotchPet/ActiveStageLayout.swift`
- `NotchPet/NotchViewModel.swift`
