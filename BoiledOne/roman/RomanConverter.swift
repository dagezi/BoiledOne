import Foundation

// Class to convert ASCII character stream into Japanese Hiragana/Katakana

class RomanConverter {
    var romanTable: [RomanTuple]

    init(_ romanTable: [RomanTuple]) {
        self.romanTable = romanTable.sorted {
            $0.from.count > $1.from.count
        }
    }

    func convert(source: String) -> String {
        var i = source.startIndex
        var result = ""

        while (i < source.endIndex) {
            var processed = false
            for tuple in romanTable {
                // Suppose most specified candidate comes first
                if (source[i...].starts(with: tuple.from)) {
                    result.append(tuple.to)
                    processed = true
                    i = source.index(i, offsetBy: tuple.from.count - tuple.rest.count)
                    break
                }
            }
            if (!processed) {
                result.append(source[i])
                i = source.index(after: i)
            }
        }
        return result
    }
}

class RomanTuple {
    let from: String
    let to: String
    let rest: String

    init(_ from: String, _ to: String, _ rest: String) {
        self.from = from
        self.to = to
        self.rest = rest
    }
}

