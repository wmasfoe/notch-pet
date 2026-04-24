//
//  NotchViewModel.swift
//  NotchPet
//

import AppKit
import Foundation
import SwiftUI

enum NotchStatus: Equatable {
    case idle
    case active
    case expanded
}

enum NotchBaseMode: String, CaseIterable, Equatable, Identifiable {
    case idle
    case active

    var id: String { rawValue }

    var title: String {
        switch self {
        case .idle:
            return "待机"
        case .active:
            return "活跃"
        }
    }
}

struct NotchStateModel: Equatable {
    var baseMode: NotchBaseMode = .idle
    var isHoverPromoted = false
    var isExpanded = false

    var status: NotchStatus {
        if isExpanded {
            return .expanded
        }
        if baseMode == .active || isHoverPromoted {
            return .active
        }
        return .idle
    }

    mutating func setBaseMode(_ mode: NotchBaseMode) {
        baseMode = mode
    }

    mutating func setHovering(_ hovering: Bool) {
        guard baseMode == .idle else {
            isHoverPromoted = false
            return
        }
        isHoverPromoted = hovering
    }

    mutating func toggleExpanded() {
        isExpanded.toggle()
    }

    mutating func collapseExpanded() {
        isExpanded = false
    }
}

@MainActor
final class NotchViewModel: ObservableObject {
    @Published private(set) var state = NotchStateModel()

    let deviceNotchRect: CGRect
    let screenRect: CGRect
    let windowHeight: CGFloat
    let hasPhysicalNotch: Bool

    private var bootPulseTask: DispatchWorkItem?

    init(
        deviceNotchRect: CGRect,
        screenRect: CGRect,
        windowHeight: CGFloat,
        hasPhysicalNotch: Bool
    ) {
        self.deviceNotchRect = deviceNotchRect
        self.screenRect = screenRect
        self.windowHeight = windowHeight
        self.hasPhysicalNotch = hasPhysicalNotch
    }

    var status: NotchStatus { state.status }
    var baseMode: NotchBaseMode { state.baseMode }
    var isExpanded: Bool { state.isExpanded }
    var isHoverPromoted: Bool { state.isHoverPromoted }

    var visibleChromeSize: CGSize {
        let notchWidth = max(deviceNotchRect.width, hasPhysicalNotch ? deviceNotchRect.width : 212)
        switch status {
        case .idle:
            return CGSize(
                width: notchWidth + (hasPhysicalNotch ? 132 : 140),
                height: max(deviceNotchRect.height, 32)
            )
        case .active:
            return CGSize(
                width: notchWidth + (hasPhysicalNotch ? 36 : 40),
                height: max(deviceNotchRect.height + 20, 48)
            )
        case .expanded:
            return CGSize(
                width: min(max(notchWidth + 176, 340), 440),
                height: 186
            )
        }
    }

    var hitTargetInsets: NSEdgeInsets {
        switch status {
        case .idle:
            return NSEdgeInsets(top: 10, left: 12, bottom: 12, right: 12)
        case .active:
            return NSEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
        case .expanded:
            return NSEdgeInsets(top: 10, left: 16, bottom: 16, right: 16)
        }
    }

    var hitTestRect: CGRect {
        let size = visibleChromeSize
        let inset = hitTargetInsets
        return CGRect(
            x: (screenRect.width - size.width) / 2 - inset.left,
            y: windowHeight - size.height - inset.top,
            width: size.width + inset.left + inset.right,
            height: size.height + inset.top + inset.bottom
        )
    }

    func setManualMode(_ mode: NotchBaseMode) {
        updateState {
            $0.setBaseMode(mode)
        }
    }

    func handleHover(_ hovering: Bool) {
        updateState {
            $0.setHovering(hovering)
        }
    }

    func toggleExpanded() {
        updateState {
            $0.toggleExpanded()
        }
    }

    func closeExpanded() {
        updateState {
            $0.collapseExpanded()
        }
    }

    func performBootAnimation() {
        bootPulseTask?.cancel()
        updateState {
            $0.setHovering(true)
        }

        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.updateState {
                $0.setHovering(false)
            }
        }
        bootPulseTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: task)
    }

    private func updateState(_ mutate: (inout NotchStateModel) -> Void) {
        var next = state
        mutate(&next)
        state = next
    }
}
