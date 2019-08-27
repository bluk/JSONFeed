#if !canImport(ObjectiveC)
import XCTest

extension JSONFeedTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JSONFeedTests = [
        ("testDecodeAuthor", testDecodeAuthor),
        ("testDecodeAuthorExtensions", testDecodeAuthorExtensions),
        ("testDecodeHubs", testDecodeHubs),
        ("testDecodeHubsExtensions", testDecodeHubsExtensions),
        ("testDecodeItem", testDecodeItem),
        ("testDecodeItemsExtensions", testDecodeItemsExtensions),
        ("testDecodeItemWithIDAsDoubleNotString", testDecodeItemWithIDAsDoubleNotString),
        ("testDecodeItemWithIDAsIntNotString", testDecodeItemWithIDAsIntNotString),
        ("testDecodeMetainfo", testDecodeMetainfo),
        ("testDecodeMinimalValidVersion1Feed", testDecodeMinimalValidVersion1Feed),
        ("testDecodeSimpleExample", testDecodeSimpleExample),
        ("testDecodeTopLevelExtensions", testDecodeTopLevelExtensions),
        ("testPublicInit", testPublicInit),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JSONFeedTests.__allTests__JSONFeedTests),
    ]
}
#endif
