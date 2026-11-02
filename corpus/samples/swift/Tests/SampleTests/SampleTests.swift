import XCTest
@testable import Sample

final class SampleTests: XCTestCase {
    func testSample() {
        XCTAssertEqual(classify(-2), "negative even")
        XCTAssertEqual(classify(5), "positive")
        XCTAssertEqual(size(3), "small")
        XCTAssertEqual(total(1, 2, 3), 6)
        XCTAssertEqual(maxOf(1, 2), 2)
        XCTAssertEqual(maxOf(2.0, 1.0), 2.0)
        XCTAssertGreaterThan(bigRun(), 0)
    }
}
