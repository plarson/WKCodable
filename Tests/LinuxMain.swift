#if os(Linux)

@testable import WKBCodableTests
import XCTest

XCTMain([
	/// WKBCodable
	testCase(WKBCodableTests.allTests),
])

#endif
