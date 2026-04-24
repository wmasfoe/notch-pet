# Deep Interview Spec: Cat Motion Reference

## Metadata

- Profile: `standard`
- Rounds: `8`
- Final ambiguity: `0.08`
- Threshold: `0.20`
- Context type: `brownfield`
- Context snapshot: `.omx/context/cat-motion-reference-20260424T095945Z.md`
- Transcript: `.omx/interviews/cat-motion-reference-20260424T102651Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | --- |
| Intent | 0.94 |
| Outcome | 0.92 |
| Scope | 0.88 |
| Constraints | 0.95 |
| Success | 0.88 |
| Context | 0.97 |

## Intent

Raise the visual quality of NotchPet so the cat animation feels faithful to the user's chosen references while the `active` shell finally reads as one Dynamic-Island-like whole instead of several disconnected black blocks.

## Desired Outcome

1. `idle`
- The cat animation frames should be restored as faithfully as possible to:
  [cat-sleep.0~_q~u_1klsn4.gif](/Users/gztd-03-01473/code/mac-notch-pet/assets/cat-sleep.0~_q~u_1klsn4.gif)
- The current `z` snore effect should remain.

2. `active`
- The cat animation frames should be restored as faithfully as possible to:
  [cat-walking.17kz07gnhsw2u.gif](/Users/gztd-03-01473/code/mac-notch-pet/assets/cat-walking.17kz07gnhsw2u.gif)
- The outer black shell should visually read as one unified Dynamic-Island-like whole.
- The pet still must not be visibly shown in the physical notch center.

3. Timing
- Frame content should aim for 100% fidelity.
- Playback timing may be adjusted and does not need to match the GIF timing exactly.

## In Scope

- Restore `idle` cat frames to match the local sleep GIF's visible frame content as closely as possible
- Keep the existing `z` snore effect in `idle`
- Restore `active` cat frames to match the local walking GIF's visible frame content as closely as possible
- Rework the `active` black shell so it reads visually as a single island
- Evaluate the implementation in this order:
  1. first try to stay in the current code-generated pixel-frame route
  2. if that cannot achieve frame-content fidelity, extract GIF frames
  3. if frames are extracted, convert them into the current `PixelPets.swift`-style frame-data route

## Out-of-Scope / Non-goals

- Do not switch to direct image-frame playback
- Do not broaden this pass into `expanded` redesign
- Do not change hover/click interaction rules in this pass
- Do not reopen the broader state-machine behavior unless a direct blocker is found
- Do not treat the GIFs as loose inspiration; the target is frame-content fidelity, not stylistic approximation

## Decision Boundaries

OMX may decide without further confirmation:

- whether the current code-generated frame route can realistically achieve full frame-content fidelity
- whether fallback extraction is necessary
- how to convert extracted frame data into the existing `PixelPets.swift`-style rendering system
- exact playback timing, so long as the frame content remains faithful
- exact geometric treatment needed to make `active` read as one unified island while still hiding center-visible pet presentation

OMX may not decide without further confirmation:

- to use direct image-frame playback instead of the current pixel-frame rendering route
- to broaden the pass into `expanded` content or unrelated state-logic work
- to relax “100% restoration” into a softer “close enough” target for frame content

## Constraints

- Brownfield SwiftUI/AppKit notch overlay app
- Local source-of-truth GIFs now live under `assets/`
- Current rendering architecture is pixel-frame-based in `PixelPets.swift`
- `idle` must keep the existing `z` snore effect
- `active` must visually read as one Dynamic-Island-like whole
- `active` still must not show the pet visibly in the physical notch center

## Testable Acceptance Criteria

1. The `idle` cat frames are restored to match the local sleep GIF's visible frame content as closely as possible while preserving the `z` snore effect.
2. The `active` cat frames are restored to match the local walking GIF's visible frame content as closely as possible.
3. If pure code-generated frames cannot achieve that fidelity, fallback extraction is used and the extracted result is still converted into the current pixel-frame rendering path.
4. No direct image-frame playback path is introduced for the cat animation.
5. `active` reads visually as one continuous island rather than three black blocks.
6. The pet is still not visibly shown in the notch center during `active`.
7. `expanded` content and existing hover/click interaction rules remain unchanged in this pass.
8. Playback timing may differ from the original GIFs without failing the brief.

## Assumptions Exposed + Resolutions

- Assumption: the GIFs are only inspiration.
  Resolution: rejected. Frame content fidelity is the target.

- Assumption: exact original timing is also mandatory.
  Resolution: rejected. Timing may be adapted.

- Assumption: if extraction is needed, direct image playback would be acceptable.
  Resolution: rejected. Even extracted data must feed the existing pixel-frame route.

## Pressure-Pass Findings

The strongest hidden ambiguity was whether “100% restoration” meant exact timing or exact frame content. The answer made the success target much more workable: preserve frame-content fidelity, but timing can still be tuned for product feel.

## Brownfield Evidence vs Inference

Evidence:

- `PixelPets.swift` already defines cat animation via code-owned pixel frames.
- The user supplied local GIF assets at `assets/cat-sleep...gif` and `assets/cat-walking...gif`.
- The user explicitly reported that the current active shell still reads like three black blocks.

Inference:

- The next implementation pass likely needs both:
  - frame-data work in `PixelPets.swift`
  - shell-shape refinement in `PetView.swift` / active chrome helpers

## Technical Context Findings

Likely touchpoints:

- `NotchPet/PixelPets.swift`
- `NotchPet/PetView.swift`
- `NotchPet/ActiveStageLayout.swift`
- `NotchPet/NotchViewModel.swift`

Local reference assets:

- `assets/cat-sleep.0~_q~u_1klsn4.gif`
- `assets/cat-walking.17kz07gnhsw2u.gif`

## Condensed Transcript

- Active shell should visually choose option `A`: one unified island
- Cat-frame target is not “close”; it is “100% restoration” for frame content
- Timing may be adjusted
- First preference is still code-generated pixel frames
- Fallback extraction is allowed only if it still feeds the current pixel-frame rendering route
- This pass is limited to:
  - idle cat frames
  - active cat frames
  - active shell unification

## Handoff

Recommended next step: `ralplan` or direct execution, depending on whether the GIF-to-pixel-frame conversion path needs one more short planning pass. The requirements are already clear enough for execution if the implementation route is considered straightforward.
