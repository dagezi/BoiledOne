import Testing
@testable import BoiledOne

struct RomanConverterTests {
    let romanConverter = RomanConverter(defaultRomanTable)

    @Test("convert test", arguments: [
        ("", "", [:]),
        ("a", "あ", [1: 1]),
        ("tyan", "ちゃん", [2:3, 3:4]),
        ("123", "123", [1:1, 2:2, 3:3]),
    ])
    func convert(src: String, expectedRoman: String, expectedMap: [Int: Int] ) {
        let result = romanConverter.convert(source: src)

        let (dest, map) = result
        #expect(dest == expectedRoman)
        #expect(map == expectedMap)
    }
}
