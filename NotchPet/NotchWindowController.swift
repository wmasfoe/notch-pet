//
//  NotchWindowController.swift
//  NotchPet
//

import AppKit
import Combine
import SwiftUI

class NotchWindowController: NSWindowController {
    let viewModel: NotchViewModel
    private let screen: NSScreen
    private var cancellables = Set<AnyCancellable>()
    
    init(screen: NSScreen, animateOnLaunch: Bool = true) {
        self.screen = screen
        
        let screenFrame = screen.frame
        let notchSize = screen.notchSize

        let deviceNotchRect = CGRect(
            x: (screenFrame.width - notchSize.width) / 2,
            y: 0,
            width: notchSize.width,
            height: notchSize.height
        )

        let windowHeight = max(notchSize.height + 32, 64)
        self.viewModel = NotchViewModel(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenFrame,
            windowHeight: windowHeight,
            hasPhysicalNotch: screen.hasPhysicalNotch
        )

        let windowFrame = Self.windowFrame(for: viewModel, on: screen)
        
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

        viewModel.$state
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateWindowFrame(animated: true)
            }
            .store(in: &cancellables)

        if animateOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                self?.viewModel.performBootAnimation()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateWindowFrame(animated: Bool) {
        guard let window else { return }

        let frame = Self.windowFrame(for: viewModel, on: screen)
        if animated {
            window.animator().setFrame(frame, display: true)
        } else {
            window.setFrame(frame, display: true)
        }
    }

    private static func windowFrame(for viewModel: NotchViewModel, on screen: NSScreen) -> NSRect {
        let chromeSize = viewModel.visibleChromeSize
        let insets = viewModel.hitTargetInsets
        let width = chromeSize.width + insets.left + insets.right
        let height = chromeSize.height + insets.top + insets.bottom
        let screenFrame = screen.frame

        return NSRect(
            x: screenFrame.midX - width / 2,
            y: screenFrame.maxY - height,
            width: width,
            height: height
        )
    }
}
