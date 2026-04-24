# Deep Interview Transcript: Active State Motion

## Metadata

- Profile: `standard`
- Rounds: `5`
- Final ambiguity: `0.15`
- Threshold: `0.20`
- Context type: `brownfield`
- Context snapshot: `.omx/context/active-state-motion-20260424T070505Z.md`
- Related planning artifacts:
  - `.omx/plans/prd-notch-overlay-states.md`
  - `.omx/plans/test-spec-notch-overlay-states.md`

## Context Summary

This interview narrowed the remaining ambiguity around the `active` notch state after the broader three-state overlay plan already existed. Earlier repo work had already:

- established `idle / active / expanded` as the intended long-term state model
- fixed a separate click-through bug in the overlay hit region
- identified that the current `active` rendering looked like a narrower island that extended downward instead of using the notch sides as activity space

The goal here was to define how `active` should look and behave without drifting into `expanded` or over-designing the animation system in one pass.

## Round Transcript

### Round 1

- Target: `outcome`
- Question:
  `active 状态的黑色区域和宠物活动方式更接近哪一种？A 左右侧翼活动；B 完整宽岛巡逻；C 左右两侧都有活动空间，中间刘海区域尽量不画内容，宠物在左右两侧切换或探头。`
- Answer:
  `C`
- Effect:
  Active was narrowed to side activity spaces around the notch. The physical notch center should not visibly carry pet content.

### Round 2

- Target: `scope`
- Question:
  `在 C 这个方向下，宠物活动时是否允许经过刘海中间？A 不允许；B 可以短暂经过；C 可以连续跑动。`
- Answer:
  `宠物不允许在刘海中间展示，否则会发生遮挡，但是可以在刘海的左右两边穿梭。`
- Effect:
  Visible traversal through the notch center was explicitly rejected. Any cross-notch movement must be hidden, masked, or represented as exit/re-entry.

### Round 3

- Target: `success`
- Question:
  `active 的“有所活动”你希望主要是哪种动作？A 左右探头/换边；B 单侧小范围走动；C 探头、跳、短跑、换边都有，但仍保持轻量。`
- Answer:
  `先试试C`
- Effect:
  The activity language was set to a lightweight lively mix: peek, jump, short run, and side switching are acceptable as long as the state still reads light and non-expanded.

### Round 4

- Target: `non-goals`
- Question:
  `active 状态最不需要的是什么，以避免它做重或做偏？`
- Answer:
  `active 状态最不需要的就是信息面板化，压根不需要展示信息；将来最多可能展示某一个图标，不会展示过多信息。过于复杂的动画现阶段也不需要，一步一步来。`
- Effect:
  This locked the main non-goals:
  - active is not an information panel
  - active currently does not need information content at all
  - future icon-level decoration is acceptable, but not dense information
  - overly complex choreographed animation is out of scope for now

### Round 5

- Target: `decision-boundary`
- Question:
  `进入实现后，哪些细节允许 OMX 直接自己定，不用再回头确认？`
- Answer:
  `omx 可以自己觉得；参考 https://github.com/farouqaldori/vibe-notch，动画一定要优雅，类似 iOS 的灵动岛。`
- Effect:
  Implementation authority was explicitly delegated to OMX for detailed motion and geometry choices, with two binding constraints:
  - the motion must feel elegant and Dynamic-Island-like
  - `vibe-notch` is a directional aesthetic reference, not a literal cloning requirement

## Final Clarity Breakdown

| Dimension | Score |
| --- | --- |
| Intent | 0.84 |
| Outcome | 0.88 |
| Scope | 0.86 |
| Constraints | 0.92 |
| Success | 0.86 |
| Context | 0.96 |

## Readiness Gates

- `Non-goals`: resolved
- `Decision Boundaries`: resolved
- `Pressure pass`: complete

## Pressure-Pass Finding

The highest-leverage refinement came from flipping the discussion from "what should active do?" to "what must active not become?". That exposed the strongest boundary in the brief: `active` must not become an information surface. Once that was explicit, the acceptable animation complexity and implementation freedom became much clearer.

## Brownfield Evidence Notes

Observed repository facts that grounded the interview:

- `idle` currently uses wider side-oriented chrome while `active` uses a narrower downward island treatment
- `activeContent` already supports motion, but the current chrome shape makes the motion feel like a retracted island rather than side activity
- planning artifacts for the broader three-state refactor already exist, so this interview only needed to clarify the remaining visual-motion contract for `active`

## Outcome

This interview is ready for handoff. The resulting brief is execution-ready for the `active` state motion/shape refinement without reopening requirements discovery.
