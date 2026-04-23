# NotchPet - Mac 刘海宠物

一个在 Mac 刘海上显示像素风宠物的 macOS 应用。

## 功能特性

- 🐱 可爱的像素风猫咪宠物
- 🎨 精致的像素艺术风格
- 🔄 自然的动画效果（眨眼、轻微弹跳）
- 🪟 在刘海两侧伸出小黑色块展示宠物，不遮挡屏幕内容
- 🖱️ 鼠标事件穿透，不影响菜单栏使用
- 🎯 参考 vibe-notch 和 mac-pet.com 的展示逻辑实现

## 系统要求

- macOS 13.0 或更高版本
- 带刘海的 MacBook（或任何 Mac，会显示在屏幕顶部中央）

## 快速开始

### 构建应用

```bash
# 克隆或下载项目后，在项目目录运行：
./build.sh
```

构建成功后，可执行文件位于 `build/NotchPet`

### 运行应用

```bash
# 直接运行
./build/NotchPet

# 或者在后台运行
./build/NotchPet &
```

### 停止应用

```bash
# 查找进程
ps aux | grep NotchPet

# 终止进程
killall NotchPet
```

## 使用方法

1. 启动应用后，刘海两侧会伸出小黑色圆角块
2. 左侧黑色块中显示可爱的像素猫咪，会自动播放眨眼和轻微弹跳动画
3. 窗口完全透明且鼠标事件穿透，不会影响菜单栏的正常使用
4. 宠物展示区域不遮挡屏幕内容，类似 Dynamic Island 的效果

## 技术实现

- SwiftUI 用于界面
- AppKit 用于窗口管理
- Canvas API 用于像素艺术渲染
- 透明悬浮窗口技术

## 参考项目

本项目参考了 [vibe-notch](https://github.com/farouqaldori/vibe-notch) 的窗口管理实现。
