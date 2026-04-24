# Deep Interview Transcript

- Profile: standard
- Context type: brownfield
- Final ambiguity: 0.14
- Threshold: 0.20
- Context snapshot: `.omx/context/notch-match-shape-20260423T111700Z.md`

## Rounds

1. Target: outcome  
Question: 在 idle / closed 状态下，你要的最终几何是哪一种？A/B/C  
Answer: close 状态我希望是 B，idle 我希望是 C

2. Target: decision-boundaries  
Question: 你希望 idle(C) 在什么条件下切换成 close(B)？  
Answer: 宠物活跃时，可以比真实刘海略宽，但必须读起来像一个完整的一体式岛；不活跃时尽量不画明显黑底；完全展开时展示信息，但用户必须手动点击 notch-pet 才会进入；活跃和非活跃现阶段先支持用户手动设置。

3. Target: non-goals  
Question: 哪些自动行为是你现在明确不要的？  
Answer: 不要：hover 自动 expanded、自动弹出信息面板

4. Target: non-goals-pressure-pass  
Question: hover 现在要不要允许把宠物从 idle 变成 active？  
Answer: 允许

## Pressure-pass finding

Earlier answers left hover behavior ambiguous. The follow-up established the exact split:
- hover may promote `idle -> active`
- hover may not trigger `expanded`
- information panels may not auto-open
