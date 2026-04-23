//
//  NotchWindow.swift
//  NotchPet
//

import AppKit

class NotchPanel: NSPanel {
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        hasShadow = false
        isMovable = false
        
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle
        ]
        
        level = .mainMenu + 3

        allowsToolTipsWhenApplicationIsInactive = true
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        isReleasedWhenClosed = true
    }
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown || event.type == .leftMouseUp ||
            event.type == .rightMouseDown || event.type == .rightMouseUp
        {
            let locationInWindow = event.locationInWindow

            if let contentView = contentView,
               contentView.hitTest(locationInWindow) == nil
            {
                let screenLocation = convertPoint(toScreen: locationInWindow)
                repostMouseEvent(event, at: screenLocation)
                return
            }
        }

        super.sendEvent(event)
    }

    private func repostMouseEvent(_ event: NSEvent, at screenLocation: NSPoint) {
        guard let screen = screen else { return }
        let cgPoint = CGPoint(
            x: screenLocation.x,
            y: screen.frame.height - screenLocation.y
        )

        let mouseType: CGEventType
        switch event.type {
        case .leftMouseDown:
            mouseType = .leftMouseDown
        case .leftMouseUp:
            mouseType = .leftMouseUp
        case .rightMouseDown:
            mouseType = .rightMouseDown
        case .rightMouseUp:
            mouseType = .rightMouseUp
        default:
            return
        }

        let button: CGMouseButton =
            event.type == .rightMouseDown || event.type == .rightMouseUp ? .right : .left

        guard let cgEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: mouseType,
            mouseCursorPosition: cgPoint,
            mouseButton: button
        ) else {
            return
        }

        cgEvent.post(tap: .cghidEventTap)
    }
}
