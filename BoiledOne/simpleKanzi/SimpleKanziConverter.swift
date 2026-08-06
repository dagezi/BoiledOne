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

    let dictionary: SimpleDictionary

    init(_ dictionary: SimpleDictionary, _ src: String) {
        self.dictionary = dictionary
        original = src
        source = original[...]
        
        updateCandidates()
    }

    func updateCandidates() {
        candidates = []
        for entry in dictionary.entries[candidateIndex...] {
            if source.starts(with: entry.source) {
                candidates.append(entry)
            }
        }
        candidateIndex = 0
    }

    private func getSelectedEndIndex() -> String.Index {
        let count = candidateIndex < candidates.count ?
            candidates[candidateIndex].source[...].count : 1

        return source.index(source.startIndex, offsetBy: count)
    }

    func getSelectedSrc() -> Substring {
        return source[source.startIndex..<getSelectedEndIndex()]
    }

    func getSelectedDest() -> Substring {
        if candidateIndex < candidates.count {
            return candidates[candidateIndex].dest[...]
        }
        return source[..<getSelectedEndIndex()]
    }

    func getUnconverted() -> Substring {
        return source[getSelectedEndIndex()...]
    }

    func fixOne() {
        source = getUnconverted()
        updateCandidates()
    }

    func fixAll() {
        source = source[source.endIndex...]
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
