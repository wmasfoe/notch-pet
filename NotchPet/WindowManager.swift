//
//  WindowManager.swift
//  NotchPet
//

import AppKit

class WindowManager {
    private(set) var windowController: NotchWindowController?
    private var isInitialLaunch = true
    
    func setupNotchWindow() {
        guard let screen = NSScreen.main else { return }
        
        windowController = NotchWindowController(
            screen: screen,
            animateOnLaunch: isInitialLaunch
        )
        isInitialLaunch = false
        windowController?.showWindow(nil)
    }
}
