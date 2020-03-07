import XCTest
@testable import StatusView

final class StatusViewTests: XCTestCase {
    lazy var statusView = StatusView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    
    func updateStatus(_ status : StatusView.Status, enabled : Bool = true, inverted: Bool = false) {
        statusView.status = status
        statusView.enabled = enabled
        statusView.inverted = inverted
        statusView.updateLayerProperties()
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSuccess() {
        updateStatus(.success)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.green)
        XCTAssertEqual(statusView.borderLayer.strokeColor, StatusView.ShapeColor.green)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testCaution() {
        updateStatus(.caution)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.orange)
        XCTAssertEqual(statusView.borderLayer.strokeColor, StatusView.ShapeColor.orange)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testFailure() {
        updateStatus(.failed)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.red)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.red)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testProcessing() {
        updateStatus(.processing)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testNone() {
        updateStatus(.none)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testSuccessDisabled() {
        updateStatus(.success, enabled: false)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testCautionDisabled() {
        updateStatus(.caution, enabled: false)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    func testFailureDisabled() {
        updateStatus(.failed, enabled: false)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertNil(statusView.borderLayer.fillColor)
    }
    
    // -------------------------------------------------------------
    
    func testSuccessInverted() {
        updateStatus(.success, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.green)
        XCTAssertEqual(statusView.borderLayer.strokeColor, StatusView.ShapeColor.green)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.green)
    }
    
    func testCautionInverted() {
        updateStatus(.caution, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.orange)
        XCTAssertEqual(statusView.borderLayer.strokeColor, StatusView.ShapeColor.orange)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.orange)
    }
    
    func testFailureInverted() {
        updateStatus(.failed, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.red)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.red)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.red)
    }
    
    func testProcessingInverted() {
        updateStatus(.processing, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.clear)
    }
    
    func testNoneInverted() {
        updateStatus(.none, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.clear)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.clear)
    }
    
    func testSuccessDisabledInverted() {
        updateStatus(.success, enabled: false, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.gray)
    }
    
    func testCautionDisabledInverted() {
        updateStatus(.caution, enabled: false, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.gray)
    }
    
    func testFailureDisabledInverted() {
        updateStatus(.failed, enabled: false, inverted: true)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.shapeColor, StatusView.ShapeColor.gray)
        XCTAssertEqual(statusView.borderLayer.fillColor, StatusView.ShapeColor.gray)
    }
    
}
