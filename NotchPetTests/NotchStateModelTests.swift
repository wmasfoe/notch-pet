import XCTest
@testable import NotchPet

final class NotchStateModelTests: XCTestCase {
    func testDefaultStateIsIdle() {
        let state = NotchStateModel()

        XCTAssertEqual(state.baseMode, .idle)
        XCTAssertEqual(state.status, .idle)
        XCTAssertFalse(state.isHoverPromoted)
        XCTAssertFalse(state.isExpanded)
    }

    func testHoverPromotesIdleToActive() {
        var state = NotchStateModel()

        state.setHovering(true)

        XCTAssertTrue(state.isHoverPromoted)
        XCTAssertEqual(state.status, .active)
    }

    func testHoverDoesNotOverrideManualActive() {
        var state = NotchStateModel(baseMode: .active, isHoverPromoted: false, isExpanded: false)

        state.setHovering(true)

        XCTAssertEqual(state.baseMode, .active)
        XCTAssertFalse(state.isHoverPromoted)
        XCTAssertEqual(state.status, .active)
    }

    func testHoverNeverExpands() {
        var state = NotchStateModel()

        state.setHovering(true)

        XCTAssertFalse(state.isExpanded)
        XCTAssertEqual(state.status, .active)
    }

    func testClickTogglesExpanded() {
        var state = NotchStateModel()

        state.toggleExpanded()
        XCTAssertTrue(state.isExpanded)
        XCTAssertEqual(state.status, .expanded)

        state.toggleExpanded()
        XCTAssertFalse(state.isExpanded)
        XCTAssertEqual(state.status, .idle)
    }

    func testCollapseFromExpandedRestoresBaseIdleWithHoverPromotion() {
        var state = NotchStateModel()
        state.setHovering(true)
        state.toggleExpanded()

        state.collapseExpanded()

        XCTAssertTrue(state.isHoverPromoted)
        XCTAssertEqual(state.status, .active)
    }

    func testCollapseFromExpandedRestoresManualActive() {
        var state = NotchStateModel(baseMode: .active, isHoverPromoted: false, isExpanded: false)
        state.toggleExpanded()

        state.collapseExpanded()

        XCTAssertEqual(state.status, .active)
        XCTAssertEqual(state.baseMode, .active)
    }

    func testManualModeSetterCanForceIdle() {
        var state = NotchStateModel(baseMode: .active, isHoverPromoted: false, isExpanded: false)

        state.setBaseMode(.idle)

        XCTAssertEqual(state.baseMode, .idle)
        XCTAssertEqual(state.status, .idle)
    }

    func testManualModeSetterCanForceActive() {
        var state = NotchStateModel()

        state.setBaseMode(.active)

        XCTAssertEqual(state.baseMode, .active)
        XCTAssertEqual(state.status, .active)
    }

    func testExpandedWinsOverEverything() {
        var state = NotchStateModel(baseMode: .active, isHoverPromoted: false, isExpanded: false)

        state.toggleExpanded()

        XCTAssertEqual(state.status, .expanded)
    }
}
