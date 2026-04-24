# Test Spec: Active State Motion Refinement

## Automated Coverage

Keep existing `NotchPetTests/NotchStateModelTests.swift` coverage as the state-model regression baseline.

The refinement must extract at least one pure helper for active layout and/or motion policy so deterministic automated coverage is possible.

Minimum required unit assertions for that helper:

1. The active quiet-zone excludes visible pet placement in the center region.
2. Any side-switch phase resolves to masked crossing or exit/re-entry, never center-visible traversal.
3. Active metrics/layout remain lighter and narrower than expanded metrics/layout.
4. The chosen active layout never exposes a visible pet lane inside the defined center quiet zone.

Do not introduce heavyweight snapshot infrastructure for this iteration.

## Manual Verification

1. Launch the app and hover the notch-pet from `idle`.
   - Expected: `active` appears without looking like a narrow downward capsule below the notch.
2. Observe the active chrome.
   - Expected: activity space is visually on the left/right sides of the notch, not as center-filled presentation.
3. Observe the pet during active motion.
   - Expected: the pet is never visibly shown in the physical notch center.
4. Observe hover/click around the center notch region.
   - Expected: the center remains visually quiet in `active`, but hover/tap continuity is preserved unless the implementation intentionally documents a narrower interaction policy.
5. If side switching occurs:
   - Expected: the transition is hidden, masked, or exit/re-entry based, and reads as elegant.
6. Click to open `expanded`.
   - Expected: information UI still appears only in `expanded`, not in `active`.
7. Collapse back out of `expanded`.
   - Expected: existing state restoration behavior still works.

## Build / Regression Commands

```bash
swift test
swift build
./build.sh
```

Execution note:
- Prefer user-run app launch for the final visual check. If the agent must launch `./build/NotchPet`, it must close the app before finishing.
