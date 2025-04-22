import XCTest
@testable import Schedy

final class StringExtensionTests: XCTestCase {
    func test_truncated_shorterThanLimit_returnsSelf() {
        let original = "Hello"
        let truncated = original.truncated(maxLength: 10)
        XCTAssertEqual(
            original,
            truncated,
            "If string is shorter than maxLength, truncated() should return the full string"
        )
    }

    func test_truncated_equalToLimit_returnsSelf() {
        let original = "HelloWorld"
        let truncated = original.truncated(maxLength: 10)
        XCTAssertEqual(
            truncated,
            original,
            "If string length == maxLength, truncated() should return the full string"
        )
    }

    func test_truncated_longerThanLimit_truncatesAndAppendsTrailing() {
        let original = "abcdefghijkl"
        let truncated = original.truncated(maxLength: 5)
        // default trailing = "..."
        XCTAssertEqual(
            truncated,
            "abcde...",
            "Should keep first 5 chars and then append '...'"
        )
    }

    func test_truncated_customTrailing() {
        let original = "SwiftIsGreat"
        let truncated = original.truncated(maxLength: 6, trailing: "---")
        XCTAssertEqual(
            truncated,
            "SwiftI---",
            "Should keep first 6 chars and append custom trailing string"
        )
    }
}
