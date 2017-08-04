import XCTest
@testable import Deau

class DeauTests: XCTestCase {
    func testParseEventResponse() {
        if let event = parse(eventResponse: fakeEventResponse) {
            XCTAssertEqual(event.name, "Fake Event")
        } else {
            XCTAssert(false, "Unable to parse fakeEventResponse")
        }
    }

    static var allTests = [
        ("testParseEventResponse", testParseEventResponse)
    ]
}
