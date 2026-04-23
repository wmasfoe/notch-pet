//
//  NotchWindowController.swift
//  NotchPet
//

import AppKit
import SwiftUI

class NotchWindowController: NSWindowController {
    let viewModel: NotchViewModel
    private let screen: NSScreen
    
    init(screen: NSScreen, animateOnLaunch: Bool = true) {
        self.screen = screen
        
        let screenFrame = screen.frame
        let notchSize = screen.notchSize
        let windowHeight: CGFloat = 260
        let windowFrame = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.maxY - windowHeight,
            width: screenFrame.width,
            height: windowHeight
        )

        let deviceNotchRect = CGRect(
            x: (screenFrame.width - notchSize.width) / 2,
            y: 0,
            width: notchSize.width,
            height: notchSize.height
        )

        self.viewModel = NotchViewModel(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenFrame,
            windowHeight: windowHeight,
            hasPhysicalNotch: screen.hasPhysicalNotch
        )
        
        let notchWindow = NotchPanel(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: notchWindow)
        
        let hostingController = NotchViewController(viewModel: viewModel)
        notchWindow.contentViewController = hostingController
        notchWindow.setFrame(windowFrame, display: true)
        notchWindow.orderFrontRegardless()

        if animateOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                self?.viewModel.performBootAnimation()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
