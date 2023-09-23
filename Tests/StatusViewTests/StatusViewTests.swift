import XCTest
import SwiftUI
@testable import StatusView

final class StatusViewTests: XCTestCase {
    lazy var statusView = CircularStatusView(size: 64.0, status: .none, color: .blue, showPercentage: false)
    
    func updateStatus(_ status : CircularStatusView.Status) {
        statusView.status = status
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSuccess() {
        updateStatus(.icon(.success()))
        XCTAssertEqual(statusView.status, .icon(.success()))
     }
    
    func testCaution() {
        updateStatus(.icon(.caution()))
        XCTAssertEqual(statusView.status, .icon(.caution()))
    }
    
    func testFailure() {
        updateStatus(.icon(.failed()))
        XCTAssertEqual(statusView.status, .icon(.failed()))
    }
    
    func testProcessing() {
        updateStatus(.progress(0.6))
        XCTAssertEqual(statusView.status, .progress(0.6))
    }
    
    func testNone() {
        updateStatus(.none)
        XCTAssertEqual(statusView.status, .none)
    }
    
    func testSuccessDisabled() {
        updateStatus(.icon(.successDisabled()))
        XCTAssertEqual(statusView.status, .icon(.successDisabled()))
    }
    
    func testCautionDisabled() {
        updateStatus(.icon(.cautionDisabled()))
        XCTAssertEqual(statusView.status, .icon(.cautionDisabled()))
    }
    
    func testFailureDisabled() {
        updateStatus(.icon(.failedDisabled()))
        XCTAssertEqual(statusView.status, .icon(.failedDisabled()))
    }
    
//    // -------------------------------------------------------------
//    
    func testSuccessInverted() {
        updateStatus(.icon(.success(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.success(.inverted)))
     }
    
    func testCautionInverted() {
        updateStatus(.icon(.caution(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.caution(.inverted)))
    }
    
    func testFailureInverted() {
        updateStatus(.icon(.failed(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.failed(.inverted)))
    }
        
    func testSuccessDisabledInverted() {
        updateStatus(.icon(.successDisabled(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.successDisabled(.inverted)))
    }
    
    func testCautionDisabledInverted() {
        updateStatus(.icon(.cautionDisabled(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.cautionDisabled(.inverted)))
    }
    
    func testFailureDisabledInverted() {
        updateStatus(.icon(.failedDisabled(.inverted)))
        XCTAssertEqual(statusView.status, .icon(.failedDisabled(.inverted)))
    }
    
}
