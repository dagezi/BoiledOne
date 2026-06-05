import SwiftUI
import OSLog


class SimpleDictionary {
    var entries: [SimpleDictionaryEntry] = []

    let logger: Logger = Logger(subsystem: "BoiledOne", category: "SimpleDictionary")

    init() {
        load(dictPath: "skk-dic.txt")
    }

    func load(dictPath: String) {
        if let fileUrl = Bundle.main.url(forResource: dictPath, withExtension: nil) {
            do {
                let content = try String(contentsOf: fileUrl, encoding: .utf8)
                var lineCount: Int = 1
                content.enumerateLines { line, stop in
                    self.parseLine(line)
                    lineCount += 1
                }
                logger.info("load: \(lineCount) entries added successfully")
                entries.sort(by: {$0.source > $1.source})
            } catch {
                logger.error("Reading from \(dictPath): \(error)")
            }
        }
    }

    func parseLine(_ line: String) {
        if line.starts(with: ";") {
            return
        }
        let tokens = line.split(separator: " ")
        if tokens.count == 2 {
            entries.append(SimpleDictionaryEntry(source: String(tokens[0]), dest: String(tokens[1])))
        }
    }
}
