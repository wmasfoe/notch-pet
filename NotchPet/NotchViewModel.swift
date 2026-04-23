//
//  NotchViewModel.swift
//  NotchPet
//

import AppKit
import Foundation
import SwiftUI

enum NotchStatus {
    case closed
    case hovered
    case expanded
}

@MainActor
final class NotchViewModel: ObservableObject {
    @Published var status: NotchStatus = .closed

    let deviceNotchRect: CGRect
    let screenRect: CGRect
    let windowHeight: CGFloat
    let hasPhysicalNotch: Bool

    private var collapseTask: DispatchWorkItem?

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

    var closedSize: CGSize {
        CGSize(
            width: max(deviceNotchRect.width, hasPhysicalNotch ? 182 : 220),
            height: max(deviceNotchRect.height + 16, 42)
        )
    }

    var hoveredSize: CGSize {
        CGSize(
            width: closedSize.width + 34,
            height: closedSize.height + 10
        )
    }

    var expandedSize: CGSize {
        CGSize(
            width: min(max(closedSize.width + 132, 320), 420),
            height: 178
        )
    }

    var currentSize: CGSize {
        switch status {
        case .closed:
            return closedSize
        case .hovered:
            return hoveredSize
        case .expanded:
            return expandedSize
        }
    }

    var contentPadding: CGFloat {
        switch status {
        case .closed:
            return 10
        case .hovered:
            return 12
        case .expanded:
            return 14
        }
    }

    var hitTestRect: CGRect {
        let size = currentSize
        return CGRect(
            x: (screenRect.width - size.width) / 2 - 18,
            y: windowHeight - size.height - 14,
            width: size.width + 36,
            height: size.height + 24
        )
    }

    func handleHover(_ hovering: Bool) {
        if hovering {
            cancelPendingCollapse()
            if status != .expanded {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    status = .hovered
                }
            }
            return
        }

        let delay: TimeInterval = status == .expanded ? 0.8 : 0.18
        scheduleCollapse(after: delay)
    }

    func toggleExpanded() {
        cancelPendingCollapse()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
            status = status == .expanded ? .hovered : .expanded
        }
    }

    func performBootAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            status = .hovered
        }

        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }
            withAnimation(.spring(response: 0.38, dampingFraction: 0.9)) {
                self.status = .closed
            }
        }
        collapseTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: task)
    }

    func closeImmediately() {
        cancelPendingCollapse()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            status = .closed
        }
    }

    private func scheduleCollapse(after delay: TimeInterval) {
        cancelPendingCollapse()
        let task = DispatchWorkItem { [weak self] in
            guard let self, self.status != .closed else { return }
            withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                self.status = .closed
            }
        }
        collapseTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    private func cancelPendingCollapse() {
        collapseTask?.cancel()
        collapseTask = nil
    }
}
