import Testing
@testable import BoiledOne

struct SimpleKanziConverterTests {
    let dictionary = makeDictionary()

    static func makeDictionary() -> SimpleDictionary {
        let dict = SimpleDictionary()
        dict.entries = [
            SimpleDictionaryEntry(source: "かんじ", dest: "漢字"),
            SimpleDictionaryEntry(source: "かんじ", dest: "感じ"),
            SimpleDictionaryEntry(source: "かん", dest: "漢"),
            SimpleDictionaryEntry(source: "じ", dest: "字"),
        ]
        return dict
    }

    @Test func constructor_initializeCandidates() {
        let converter = SimpleKanziConverter(dictionary, "かんじ")

        #expect(converter.candidates.map(\.dest) == ["漢字", "感じ", "漢"])
        #expect(converter.getSource() == "かんじ")
        #expect(converter.getSelectedSrc() == "かんじ")
        #expect(converter.getSelectedDest() == "漢字")
        #expect(converter.getUnconverted() == "")
    }

    @Test func constructor_initializeHiraganaCandidate_ifNoMatch() {
        let converter = SimpleKanziConverter(dictionary, "ほげ")

        #expect(converter.candidates.isEmpty)
        #expect(converter.getSelectedSrc() == "ほ")
        #expect(converter.getSelectedDest() == "ほ")
        #expect(converter.getUnconverted() == "げ")
    }

    @Test func selectRelatively() {
        let converter = SimpleKanziConverter(dictionary, "かんじ")

        converter.selectRelatively(diff: 1)
        #expect(converter.getSelectedDest() == "感じ")

        converter.selectRelatively(diff: 1)
        #expect(converter.getSelectedSrc() == "かん")
        #expect(converter.getSelectedDest() == "漢")
        #expect(converter.getUnconverted() == "じ")

        converter.selectRelatively(diff: 1)
        #expect(converter.getSelectedSrc() == "か")
        #expect(converter.getSelectedDest() == "か")
        #expect(converter.getUnconverted() == "んじ")

        converter.selectRelatively(diff: 1)
        #expect(converter.getSelectedDest() == "漢字")
    }

    @Test func fixOne() {
        let converter = SimpleKanziConverter(dictionary, "かんじ")
        converter.selectRelatively(diff: 2)  // 漢

        converter.fixOne()
        #expect(!converter.isEmpty())
        #expect(converter.getSource() == "じ")
        #expect(converter.getSelectedSrc() == "じ")
        #expect(converter.getSelectedDest() == "字")

        converter.fixOne()
        #expect(converter.getSource() == "")
        #expect(converter.isEmpty())
    }

    @Test func fixAll() {
        let converter = SimpleKanziConverter(dictionary, "かんじかん")

        converter.fixAll()
        #expect(converter.isEmpty())
        #expect(converter.candidates.isEmpty)
    }

    @Test func extendCandidate_shrink() {
        let converter = SimpleKanziConverter(dictionary, "かんじ")

        converter.extendCandidate(diff: -1)
        #expect(converter.candidates.map(\.dest) == ["漢"])
        #expect(converter.getSelectedSrc() == "かん")
        #expect(converter.getSelectedDest() == "漢")
        #expect(converter.getUnconverted() == "じ")
    }

    @Test func extendCandidate_extend() {
        let converter = SimpleKanziConverter(dictionary, "かんじ")
        converter.extendCandidate(diff: -1)  // 漢

        // 長くしても候補は変わらず、のびた部分はそのまま付く
        converter.extendCandidate(diff: 1)
        #expect(converter.candidates.map(\.dest) == ["漢"])
        #expect(converter.getSelectedSrc() == "かんじ")
        #expect(converter.getSelectedDest() == "漢じ")
        #expect(converter.getUnconverted() == "")

        // source の長さを超えてはのびない
        converter.extendCandidate(diff: 1)
        #expect(converter.getSelectedSrc() == "かんじ")
    }

    @Test func extendCandidate_extendCandidate_ifNoMatch() async {
        let converter = SimpleKanziConverter(SimpleKanziConverterTests.makeDictionary(), "ほげ")
        converter.extendCandidate(diff: 1)
        #expect(converter.getSelectedSrc() == "ほげ")
        #expect(converter.getSelectedDest() == "ほげ")
        #expect(converter.getUnconverted() == "")

        converter.extendCandidate(diff: -1)
        #expect(converter.getSelectedSrc() == "ほ")
        #expect(converter.getSelectedDest() == "ほ")
        #expect(converter.getUnconverted() == "げ")
    }

    @Test func extendCandidate_shrinkNothing_ifNoMatch() async {
        let converter = SimpleKanziConverter(SimpleKanziConverterTests.makeDictionary(), "ほげ")
        converter.extendCandidate(diff: -1)
        #expect(converter.getSelectedSrc() == "ほ")
        #expect(converter.getSelectedDest() == "ほ")
        #expect(converter.getUnconverted() == "げ")
    }

    @Test func extendCandidate_shrinkNothing_ifKanaIsSelected() async {
        let converter = SimpleKanziConverter(SimpleKanziConverterTests.makeDictionary(), "かんじ")
        converter.selectRelatively(diff: 3)  // candidateIndex == candidates.count
        converter.extendCandidate(diff: -1)
        #expect(converter.getSelectedSrc() == "か")
        #expect(converter.getSelectedDest() == "か")
        #expect(converter.getUnconverted() == "んじ")
    }
}
