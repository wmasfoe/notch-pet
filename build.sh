#!/bin/bash

# NotchPet 构建脚本

echo "🐱 开始构建 NotchPet..."

# 创建构建目录
mkdir -p build
mkdir -p .build/ModuleCache

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-.build/ModuleCache}"

SDKROOT="${SDKROOT:-/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk}"
if [ ! -d "$SDKROOT" ]; then
    SDKROOT="$(xcrun --show-sdk-path --sdk macosx)"
fi

# 编译所有 Swift 文件
swiftc -o build/NotchPet \
    -module-cache-path "$CLANG_MODULE_CACHE_PATH" \
    -sdk "$SDKROOT" \
    -target arm64-apple-macos13.0 \
    NotchPet/NotchPetApp.swift \
    NotchPet/AppDelegate.swift \
    NotchPet/WindowManager.swift \
    NotchPet/NotchWindow.swift \
    NotchPet/NotchWindowController.swift \
    NotchPet/NotchViewController.swift \
    NotchPet/NotchViewModel.swift \
    NotchPet/ActiveStageLayout.swift \
    NotchPet/NotchShape.swift \
    NotchPet/NSScreen+Notch.swift \
    NotchPet/PetView.swift \
    NotchPet/PixelPets.swift \
    -framework AppKit \
    -framework SwiftUI

if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "📦 可执行文件位于: build/NotchPet"
    echo ""
    echo "运行应用："
    echo "  ./build/NotchPet"
else
    echo "❌ 构建失败"
    exit 1
fi
