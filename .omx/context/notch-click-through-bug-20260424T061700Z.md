# Notch Click-Through Bug Context

## Task
Fix the bug where launching the built NotchPet app makes roughly the top third of the screen unclickable.

## Desired Outcome
Only the actual notch-pet interaction area should receive mouse events. All transparent overlay area outside the current visible chrome/hit rect must pass through to underlying apps and the menu bar.

## Known Evidence
- `NotchWindowController` creates a full-screen-width top `NSPanel` with height `260`.
- `NotchViewController` only overrides `NSHostingView.hitTest`, returning `nil` outside `viewModel.hitTestRect`.
- `NotchPanel` still sets `ignoresMouseEvents = false` for the entire full-width panel.
- `NotchPanel.sendEvent` tries to repost outside mouse events as `CGEvent`, which can fail without permissions and still means the transparent panel first intercepts mouse events.

## Constraints
- Do not launch the built app unless necessary; if launched for visual/runtime verification, close it before finishing.
- Avoid broad rewrites; fix event pass-through with a minimal AppKit-level change.
- Keep notch-pet hover/click interaction inside the intended hit region.

## Likely Touchpoints
- `NotchPet/NotchWindow.swift`
- `NotchPet/NotchViewController.swift`
- `NotchPet/NotchWindowController.swift`
- `NotchPet/NotchViewModel.swift`

## Team Runtime Note
The user invoked `$team`, but this shell environment cannot find `omx` or `tmux`, and `$TMUX` is unset. Durable OMX team launch is blocked in this execution environment.
