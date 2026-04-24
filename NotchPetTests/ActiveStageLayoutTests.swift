import XCTest
@testable import NotchPet

final class ActiveStageLayoutTests: XCTestCase {
    func testQuietZoneExcludesVisiblePetPlacementInCenterRegion() {
        let layout = ActiveStageLayout(
            containerSize: CGSize(width: 308, height: 48),
            notchWidth: 184
        )
        let spriteWidth = CGFloat(CatPixelArtMetrics.walkingFrameWidth) * 2.4

        for sampleTime in stride(from: 0.0, through: 5.0, by: 0.1) {
            let sample = layout.sample(elapsed: sampleTime, spriteWidth: spriteWidth)
            if sample.visible {
                XCTAssertFalse(
                    layout.overlapsQuietZone(spriteX: sample.spriteX, spriteWidth: spriteWidth),
                    "Visible sample at \(sampleTime) should not overlap quiet zone"
                )
            }
        }
    }

    func testSwitchPhasesNeverShowCenterVisibleTraversal() {
        let layout = ActiveStageLayout(
            containerSize: CGSize(width: 308, height: 48),
            notchWidth: 184
        )
        let spriteWidth = CGFloat(CatPixelArtMetrics.walkingFrameWidth) * 2.4

        let rightSwitch = layout.sample(elapsed: 2.2, spriteWidth: spriteWidth)
        XCTAssertEqual(rightSwitch.phase, .switchToRight)
        XCTAssertFalse(rightSwitch.visible)

        let leftSwitch = layout.sample(elapsed: 4.8, spriteWidth: spriteWidth)
        XCTAssertEqual(leftSwitch.phase, .switchToLeft)
        XCTAssertFalse(leftSwitch.visible)
    }

    @MainActor
    func testActiveMetricsRemainNarrowerThanExpandedMetrics() {
        let viewModel = NotchViewModel(
            deviceNotchRect: CGRect(x: 0, y: 0, width: 184, height: 32),
            screenRect: CGRect(x: 0, y: 0, width: 1512, height: 982),
            windowHeight: 64,
            hasPhysicalNotch: true
        )

        viewModel.setManualMode(.active)
        let activeSize = viewModel.visibleChromeSize

        viewModel.toggleExpanded()
        let expandedSize = viewModel.visibleChromeSize

        XCTAssertLessThan(activeSize.width, expandedSize.width)
        XCTAssertLessThan(activeSize.height, expandedSize.height)
    }

    func testVisibleSamplesStayWithinSideBays() {
        let layout = ActiveStageLayout(
            containerSize: CGSize(width: 308, height: 48),
            notchWidth: 184
        )
        let spriteWidth = CGFloat(CatPixelArtMetrics.walkingFrameWidth) * 2.4

        for sampleTime in stride(from: 0.0, through: 5.0, by: 0.1) {
            let sample = layout.sample(elapsed: sampleTime, spriteWidth: spriteWidth)
            guard sample.visible else { continue }

            let bay = sample.side == .left ? layout.leftBayRect : layout.rightBayRect
            XCTAssertGreaterThanOrEqual(sample.spriteX, bay.minX)
            XCTAssertLessThanOrEqual(sample.spriteX + spriteWidth, bay.maxX + 0.01)
        }
    }
}
