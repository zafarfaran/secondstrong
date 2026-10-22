import Testing
@testable import SSCore

@Suite struct RGBTests {
    @Test func parsesHashPrefixedHex() throws {
        let rgb = try #require(RGB(hex: "#3B322C"))
        #expect(rgb == RGB(red: 59.0 / 255, green: 50.0 / 255, blue: 44.0 / 255))
    }

    @Test func parsesBareHex() {
        #expect(RGB(hex: "FFFFFF") == RGB(red: 1, green: 1, blue: 1))
    }

    @Test(arguments: ["", "#FFF", "#GGGGGG", "#1234567"])
    func rejectsMalformedHex(_ input: String) {
        #expect(RGB(hex: input) == nil)
    }
}
