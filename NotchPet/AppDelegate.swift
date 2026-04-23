//
//  AppDelegate.swift
//  NotchPet
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowManager: WindowManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置为辅助应用，不显示在 Dock
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // 创建窗口管理器
        windowManager = WindowManager()
        windowManager?.setupNotchWindow()
    }
}
