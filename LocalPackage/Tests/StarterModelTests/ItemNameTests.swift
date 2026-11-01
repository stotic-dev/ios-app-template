//
//  ItemNameTests.swift
//  StarterModelTests
//

import StarterModel
import Testing

struct ItemNameTests {

    @Test("前後の空白を取り除いた名前を持つ")
    func trimsWhitespaces() throws {
        let name = try ItemName("  りんご \n")

        #expect(name.value == "りんご")
    }

    @Test(
        "空白だけ、または上限を超える名前は作れない",
        arguments: ["", "   ", String(repeating: "あ", count: ItemName.maxLength + 1)]
    )
    func rejectsInvalidName(rawValue: String) {
        #expect(throws: DomainError.invalidItemName) {
            try ItemName(rawValue)
        }
    }

    @Test("上限ちょうどの文字数は作れる")
    func acceptsMaxLength() throws {
        let rawValue = String(repeating: "あ", count: ItemName.maxLength)

        let name = try ItemName(rawValue)

        #expect(name.value == rawValue)
    }

}
