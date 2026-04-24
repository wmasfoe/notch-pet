# Test Spec: Notch Overlay State Refactor

## Automated Coverage

Add a `NotchPetTests` target and cover:

1. Initial state defaults to `idle` or the chosen explicit base mode.
2. Hover changes `idle -> active`.
3. Hover while already `active` does not enter `expanded`.
4. Hover never toggles `expanded`.
5. Click toggles `expanded`.
6. Collapse from `expanded` restores the prior manual/base mode.
7. Manual mode setter can force `idle`.
8. Manual mode setter can force `active`.
9. Inactivity/sleep logic never opens `expanded`.
10. Derived render-state precedence follows:
   - expanded wins over everything
   - base `active` wins over hover
   - base `idle` + hover promotion renders `active`
   - base `idle` + no hover renders `idle`

## Manual Verification

1. Launch the app and observe the idle notch state.
   - Expected: pet appears attached to the notch edge and visible idle chrome does not extend beyond the physical notch by more than 8 px per side.
2. Hover the notch-pet.
   - Expected: island promotes to `active`, remains one contiguous silhouette, no info panel opens, and idle hover affordance remains usable without visibly detached side blocks.
3. Click the notch-pet.
   - Expected: `expanded` opens and shows extra information.
4. Click again to collapse.
   - Expected: returns to the previously selected non-expanded mode.
5. Use the manual control in `expanded` to switch between `idle` and `active`.
   - Expected: both states are user-settable in this iteration.
6. Verify non-expanded visuals.
   - Expected: no detached left/right blocks in either `idle` or `active`.
7. Verify active width bound.
   - Expected: visible active chrome does not extend beyond the physical notch by more than 24 px per side.

## Build / Regression Commands

```bash
swift test
swift build
./build.sh
```

Execution note:
- `build.sh` is in scope for this task and must be updated if the refactor introduces required files that are not currently compiled by the script.
