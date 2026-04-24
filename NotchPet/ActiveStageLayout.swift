//
//  ActiveStageLayout.swift
//  NotchPet
//

import CoreGraphics
import Foundation
import SwiftUI

enum ActiveStageSide: Equatable {
    case left
    case right
}

enum ActiveMotionPhase: Equatable {
    case leftPeek
    case leftRun
    case switchToRight
    case rightPeek
    case rightRun
    case switchToLeft
}

struct ActiveMotionSample: Equatable {
    let phase: ActiveMotionPhase
    let side: ActiveStageSide
    let visible: Bool
    let spriteX: CGFloat
    let mirrored: Bool
    let bodyLift: CGFloat
    let shadowScale: CGFloat
}

struct ActiveStageLayout: Equatable {
    let containerSize: CGSize
    let quietZoneWidth: CGFloat
    let bridgeHeight: CGFloat
    let sideInset: CGFloat
    let bayInset: CGFloat

    init(containerSize: CGSize, notchWidth: CGFloat) {
        self.containerSize = containerSize

        let maxQuietWidth = max(containerSize.width - 88, 72)
        self.quietZoneWidth = min(max(notchWidth - 6, 72), maxQuietWidth)
        self.bridgeHeight = min(max(containerSize.height * 0.42, 15), max(containerSize.height - 14, 15))
        self.sideInset = 8
        self.bayInset = 6
    }

    var quietZoneMinX: CGFloat {
        (containerSize.width - quietZoneWidth) / 2
    }

    var quietZoneMaxX: CGFloat {
        quietZoneMinX + quietZoneWidth
    }

    var leftBayRect: CGRect {
        CGRect(
            x: sideInset,
            y: max(bridgeHeight - 3, 0),
            width: max(quietZoneMinX - sideInset - bayInset, 1),
            height: max(containerSize.height - bridgeHeight + 3, 1)
        )
    }

    var rightBayRect: CGRect {
        let originX = min(quietZoneMaxX + bayInset, containerSize.width - sideInset - 1)
        return CGRect(
            x: originX,
            y: max(bridgeHeight - 3, 0),
            width: max(containerSize.width - sideInset - originX, 1),
            height: max(containerSize.height - bridgeHeight + 3, 1)
        )
    }

    func spriteLeadingRange(on side: ActiveStageSide, spriteWidth: CGFloat) -> ClosedRange<CGFloat> {
        let bayRect = side == .left ? leftBayRect : rightBayRect
        let minX = bayRect.minX + 4
        let maxX = max(minX, bayRect.maxX - spriteWidth - 4)
        return minX...maxX
    }

    func overlapsQuietZone(spriteX: CGFloat, spriteWidth: CGFloat) -> Bool {
        let spriteMinX = spriteX + 1
        let spriteMaxX = spriteX + spriteWidth - 1
        return spriteMaxX > quietZoneMinX && spriteMinX < quietZoneMaxX
    }

    func sample(elapsed: TimeInterval, spriteWidth: CGFloat) -> ActiveMotionSample {
        let cycle = 5.0
        let phaseTime = elapsed.truncatingRemainder(dividingBy: cycle)
        let leftRange = spriteLeadingRange(on: .left, spriteWidth: spriteWidth)
        let rightRange = spriteLeadingRange(on: .right, spriteWidth: spriteWidth)

        switch phaseTime {
        case 0..<0.7:
            let spriteX = max(leftRange.lowerBound, leftRange.upperBound - min((leftRange.upperBound - leftRange.lowerBound) * 0.18, 10))
            let bob = abs(sin(CGFloat(phaseTime / 0.7) * .pi)) * 2.3
            return ActiveMotionSample(
                phase: .leftPeek,
                side: .left,
                visible: true,
                spriteX: spriteX,
                mirrored: true,
                bodyLift: bob,
                shadowScale: 0.9
            )

        case 0.7..<2.05:
            let phaseProgress = normalizedProgress(phaseTime, start: 0.7, duration: 1.35)
            let oscillation = pingPong(phaseProgress)
            let spriteX = lerp(leftRange.lowerBound, leftRange.upperBound, oscillation)
            return ActiveMotionSample(
                phase: .leftRun,
                side: .left,
                visible: true,
                spriteX: spriteX,
                mirrored: phaseProgress < 0.5,
                bodyLift: sin(CGFloat(phaseProgress) * .pi * 4) * 1.4 + 2.0,
                shadowScale: 0.78
            )

        case 2.05..<2.5:
            return ActiveMotionSample(
                phase: .switchToRight,
                side: .right,
                visible: false,
                spriteX: rightRange.lowerBound,
                mirrored: false,
                bodyLift: 0,
                shadowScale: 0.72
            )

        case 2.5..<3.2:
            let spriteX = min(rightRange.upperBound, rightRange.lowerBound + min((rightRange.upperBound - rightRange.lowerBound) * 0.18, 10))
            let bob = abs(sin(CGFloat((phaseTime - 2.5) / 0.7) * .pi)) * 2.3
            return ActiveMotionSample(
                phase: .rightPeek,
                side: .right,
                visible: true,
                spriteX: spriteX,
                mirrored: false,
                bodyLift: bob,
                shadowScale: 0.9
            )

        case 3.2..<4.55:
            let phaseProgress = normalizedProgress(phaseTime, start: 3.2, duration: 1.35)
            let oscillation = pingPong(phaseProgress)
            let spriteX = lerp(rightRange.lowerBound, rightRange.upperBound, oscillation)
            return ActiveMotionSample(
                phase: .rightRun,
                side: .right,
                visible: true,
                spriteX: spriteX,
                mirrored: phaseProgress >= 0.5,
                bodyLift: sin(CGFloat(phaseProgress) * .pi * 4) * 1.4 + 2.0,
                shadowScale: 0.78
            )

        default:
            return ActiveMotionSample(
                phase: .switchToLeft,
                side: .left,
                visible: false,
                spriteX: leftRange.upperBound,
                mirrored: true,
                bodyLift: 0,
                shadowScale: 0.72
            )
        }
    }

    private func normalizedProgress(_ value: TimeInterval, start: TimeInterval, duration: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 0 }
        return min(max(CGFloat((value - start) / duration), 0), 1)
    }

    private func pingPong(_ progress: CGFloat) -> CGFloat {
        1 - abs(2 * progress - 1)
    }

    private func lerp(_ from: CGFloat, _ to: CGFloat, _ progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }
}

struct ActiveChromeShape: Shape {
    var quietZoneWidth: CGFloat
    var bridgeHeight: CGFloat
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(quietZoneWidth, bridgeHeight) }
        set {
            quietZoneWidth = newValue.first
            bridgeHeight = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let topRadius = min(topCornerRadius, rect.width / 2, rect.height / 2)
        let bottomRadius = min(bottomCornerRadius, rect.width / 2, rect.height / 2)

        return NotchShape(
            topCornerRadius: topRadius,
            bottomCornerRadius: bottomRadius
        )
        .path(in: rect)
    }
}
