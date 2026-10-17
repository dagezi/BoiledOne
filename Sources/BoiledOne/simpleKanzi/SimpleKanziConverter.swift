// Simple Kanzi Converter
// It tries to covert the staring strings with matching strings

struct SimpleDictionaryEntry {
    let source: String  // Source Hiragana
    let dest: String // Destination Kanzi or other

    // TODO: Add frequency 
}

class SimpleKanziConverter {
    let original: String   // Source Hiragana String
    var source: Substring
    var candidates: [SimpleDictionaryEntry] = []
    var candidateIndex: Int = 0 // Index in candidates
    var consumedLen: Int? = nil

    let dictionary: SimpleDictionary

    init(_ dictionary: SimpleDictionary, _ src: String) {
        self.dictionary = dictionary
        original = src
        source = original[...]
        
        updateCandidates()
    }

    func updateCandidates() {
        candidates = []
        let maxLen = consumedLen ?? .max
        for entry in dictionary.entries {
            if source.starts(with: entry.source) && entry.source.count <= maxLen {
                candidates.append(entry)
            }
        }
        candidateIndex = 0
    }


    private func getConsumedLen() -> Int {
        return consumedLen ?? (
            candidateIndex < candidates.count ?
            candidates[candidateIndex].source[...].count : 1)
    }

    private func getSelectedEndIndex() -> String.Index {        
        let count = getConsumedLen()

        return source.index(source.startIndex, offsetBy: count)
    }

    func getSelectedSrc() -> Substring {
        return source[source.startIndex..<getSelectedEndIndex()]
    }

    func getSelectedDest() -> Substring {
        if candidateIndex < candidates.count {
            var converted = candidates[candidateIndex].dest[...]
            if let len = consumedLen {
                let skip = candidates[candidateIndex].source.count
                if (len > skip) {
                    let suffixFrom = source.index(source.startIndex, offsetBy: skip)
                    let suffixTo = source.index(source.startIndex, offsetBy: len)
                    converted = converted + source[suffixFrom..<suffixTo]
                }
            }
            return converted
        }
        return source[..<getSelectedEndIndex()]
    }

    func getUnconverted() -> Substring {
        return source[getSelectedEndIndex()...]
    }

    func extendCandidate(diff: Int) {
        let count = getConsumedLen()

        if diff < 0 {
            let newLen = max(1, count + diff)
            consumedLen = newLen
            if (candidateIndex < candidates.count && newLen < candidates[candidateIndex].source.count) {
                updateCandidates()
            }
        } else {
            // 長くなるときは候補を変えない。未変換部分がのびるだけ。
            consumedLen = min(source.count, count + diff)
        }
    }

    func fixOne() {
        source = getUnconverted()
        consumedLen = nil
        updateCandidates()
    }

    func fixAll() {
        source = source[source.endIndex...]
        consumedLen = nil
        updateCandidates()
    }

    func selectRelatively(diff: Int) {
        guard !candidates.isEmpty else { return }
        candidateIndex = (candidateIndex + diff).modulo(candidates.count + 1)
    }

    func isEmpty() -> Bool {
        return source.isEmpty
    }
}
