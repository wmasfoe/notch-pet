# Active State Motion Context

## Task Statement
Clarify how the NotchPet active state should look and behave after the idle state is now acceptable.

## Desired Outcome
Active state should make the pet visibly active instead of resting, while keeping the notch/pet interaction aligned with the user's Dynamic Island expectations.

## Stated Problem
Current active state appears to retract the black blocks beside the notch and expand downward below the notch.

## Known Code Facts
- `NotchViewModel.visibleChromeSize` currently sets idle width to `notchWidth + 132` on physical notch devices.
- `NotchViewModel.visibleChromeSize` currently sets active width to `notchWidth + 36` and height to `deviceNotchRect.height + 20`.
- `PetView.chromeBody` uses a special horizontal wing renderer only for idle.
- Active uses `islandChrome`, so it becomes a full island shape under the notch rather than the idle left/right wing stage.
- `activeContent` currently runs `patrolStage`, so the pet has walking movement but within a narrower, downward island.

## Constraints
- Do not implement inside deep-interview mode.
- Ask one question per round.
- Keep active distinct from expanded; expanded still requires manual click.
- Preserve current preference: do not launch the built app unless necessary; if launched, close it before finishing.

## Unknowns
- Whether active should keep left/right wing layout, become a wider one-piece island, or use two side stages without center fill.
- Whether active pet should walk across both sides, jump/peek, or switch side-to-side.
- How much downward expansion is acceptable in active.
- What active should do on hover vs manually-set active mode.

## Clarified Decisions
- Active should follow option C: left and right sides are the activity spaces, while the physical notch center should not visibly carry pet content.
- The pet must not be visible in the notch center because it will be occluded. It may shuttle between left and right sides, but the transition through the notch center should be hidden, masked, or represented as exit/entry rather than visible traversal.
- Active motion should first try a lightweight lively mix: peek, jump, short run, and side switching are all acceptable as long as it does not become expanded/info-panel behavior.

## Likely Touchpoints
- `NotchPet/NotchViewModel.swift`
- `NotchPet/PetView.swift`
- `NotchPet/NotchWindowController.swift`
