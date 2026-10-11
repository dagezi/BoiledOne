import SwiftUI
import OSLog


class SimpleDictionary {
    var entries: [SimpleDictionaryEntry] = []

    let logger: Logger = Logger(subsystem: "BoiledOne", category: "SimpleDictionary")

    init() {
        load()
    }

    // Resource directoryにある "*.dict" fileを読み込む。
    // 辞書式に file名が先にくる辞書のほうが優先順位が高くなる。
    func load() {
        let resourcePath = Bundle.main.resourceURL!

        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(
                at: resourcePath, 
                includingPropertiesForKeys: nil, 
                options: .skipsHiddenFiles
            )
            var dictUrls = fileUrls.filter {$0.pathExtension == "dict"}
            dictUrls.sort(by: { $0.path < $1.path })
            for dictUrl in dictUrls {
                loadDict(dictUrl)
            }
        } catch {
            logger.error("Reading Resource directory: \(error)")
        }
        entries.sort(by: {$0.source > $1.source})
    }

    private func loadDict(_ dictUrl: URL) {
        var lineCount: Int = 0
        do {
            let content: String = try String(contentsOf: dictUrl, encoding: .utf8)
            content.enumerateLines { line, stop in
                lineCount += 1
                self.parseLine(line)
            }
            logger.info("load: \(lineCount) entries from \(dictUrl) successfully")
        } catch {
            logger.error("Reading from \(dictUrl): \(error)")
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
