import Foundation

// Class to convert ASCII character stream into Japanese Hiragana/Katakana

class RomanConverter {
    var romanTable: [RomanTuple]

    init(_ romanTable: [RomanTuple]) {
        self.romanTable = romanTable.sorted {
            $0.from.count > $1.from.count
        }
    }

    // Converts Roman String into Hiragana and returns a map from each Hiragana index to Roma-zi index
    func convert(source: String) -> (String, [Int: Int]) {
        var i = 0
        var result = ""
        
        // A map from position of hiragana to source
        // Note that we can't save `result`'s index as it's modifiable
        var hiraToRomaMap: [Int: Int] = [:]

        while (i < source.count) {
            var processed = false
            let ix: String.Index = source.index(source.startIndex, offsetBy: i)
            for tuple in romanTable {
                // Suppose most specified candidate comes first
                if (source[ix...].starts(with: tuple.from)) {
                    result.append(tuple.to)
                    processed = true
                    i += tuple.from.count - tuple.rest.count
                    break
                }
            }
            if (!processed) {
                result.append(source[ix])
                i += 1
            }
            hiraToRomaMap[result.count] = i
        }
        return (result, hiraToRomaMap)
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

let romanConverter = RomanConverter(defaultRomanTable)
