# AGENTS.md - NotchPet 项目指南

## 项目概述

NotchPet 是一个 macOS 原生应用，在 MacBook 刘海（Notch）两侧显示像素风宠物。参考了 [vibe-notch](https://github.com/farouqaldori/vibe-notch) 的窗口管理实现和 [mac-pet.com](https://mac-pet.com/zh/) 的展示逻辑。

## 技术栈

- 语言：Swift 5.9+
- 框架：SwiftUI + AppKit
- 最低系统要求：macOS 13.0
- 构建方式：swiftc 命令行编译（见 `build.sh`）

## 项目结构

```
NotchPet/
├── NotchPetApp.swift          # 应用入口，@main
├── AppDelegate.swift          # 应用代理，初始化窗口管理器
├── WindowManager.swift        # 窗口生命周期管理
├── NotchWindow.swift          # NSPanel 子类，透明悬浮窗口
├── NotchWindowController.swift # 窗口控制器，定位窗口到刘海区域
├── NSScreen+Notch.swift       # NSScreen 扩展，检测刘海尺寸
├── PetView.swift              # 主视图，在刘海两侧伸出黑色块展示宠物
├── PixelPets.swift            # 像素风宠物图形（猫、狗、皮卡丘）
└── Info.plist                 # 应用配置（LSUIElement=true 隐藏 Dock 图标）
```

## 核心设计决策

### 窗口定位

- 窗口位于屏幕顶部中央，覆盖刘海区域 + 两侧各延伸 40px
- 使用 `NSPanel`（非 `NSWindow`）实现非激活面板行为
- `level = .mainMenu + 3` 确保显示在菜单栏之上
- `ignoresMouseEvents = true` 让鼠标事件穿透，不影响菜单栏使用
- `collectionBehavior` 设置为在所有桌面空间可见

### 宠物展示逻辑

- 刘海本身是椭圆形黑色区域，直接在其中绘制内容会被遮挡
- 参考 vibe-notch 的做法：在刘海两侧伸出小黑色圆角块作为宠物"舞台"
- 黑色块只有底部圆角，顶部与刘海无缝衔接
- 宠物使用 Canvas API 逐像素绘制，实现像素艺术风格

### 动画

- 眨眼动画：每 3 秒触发一次，持续 0.2 秒
- 轻微弹跳：上下 2px 的 easeInOut 循环动画

## 构建与运行

```bash
# 构建
./build.sh

# 运行
./build/NotchPet

# 停止
killall NotchPet
```

## 刘海检测

通过 `NSScreen.auxiliaryTopLeftArea` 和 `auxiliaryTopRightArea` API 检测物理刘海。无刘海设备使用默认尺寸 200x30。

## 已知限制

- 当前仅支持主屏幕，不支持多显示器
- 像素宠物图形是硬编码的，未来可考虑从外部资源加载
- 没有菜单栏图标或设置界面
- 没有开机自启动功能

## 扩展方向

- 添加更多宠物类型和动画帧（行走、睡觉等）
- 添加菜单栏图标用于切换宠物和退出应用
- 支持用户自定义像素宠物
- 添加宠物互动（点击反馈）
- 支持多显示器
