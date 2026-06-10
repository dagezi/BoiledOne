import Carbon
class KanaMode : BoiledOneMode {
    let hira: String
    var result: String
    var kataChars: Int

    init(_ context: BoiledOneContext) {
        hira = romanConverter.convert(source: context.rawString)
        result = hira
        kataChars = 0

        super.init()

        commandMap = [
            CommandEntry(kVK_ANSI_G, [.control], cancelCommand),
            CommandEntry(kVK_ANSI_J, [.control], simpleKanziStartCommand),
            CommandEntry(kVK_ANSI_K, [.control], kanaKataHiraCommand),
            CommandEntry(kVK_ANSI_L, [.control], kanaFixCommand),
            CommandEntry(kVK_ANSI_M, [.control], kanaFixAndExecuteCommand),
            CommandEntry(kVK_Escape, [], cancelCommand),
            CommandEntry(kVK_Return, [], kanaFixAndExecuteCommand),
        ]

        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], kanaFixAndExecuteCommand))
        }
        fallbackCommand = kanaFixAndExecuteCommand
    }

    override func getShowString(_ context: BoiledOneContext) -> [(Substring, Int)] {
        return [
            (result[...], kTSMHiliteSelectedConvertedText),
        ]
    }

    func shrinkKatakana() {
        if kataChars > 0 {
            kataChars -= 1
        } else {
            kataChars = hira.count
        }

        if (kataChars == 0) {
            result = hira
        } else {
            result = hiraToKata(hira, range: hira.startIndex ..< hira.index(hira.startIndex, offsetBy: kataChars))
        }
    }
}

let kanaStartCommand = BoiledOneCommand(
    name: "KanaStartCommand",
    handler: {context in
        context.mode = KanaMode(context)
        return .handled
    }
)

let kanaKataHiraCommand = BoiledOneCommand(
    name: "KanaKataHiraCommand",
    handler: {context in
        guard let mode: KanaMode = context.mode as? KanaMode else {
            return .handled
        }
        mode.shrinkKatakana()
        return .handled
    }
)

let kanaFixCommand = BoiledOneCommand(
    name: "KanaFixCommand",
    handler: {context in
        guard let mode: KanaMode = context.mode as? KanaMode else {
            return .handled
        }
        context.insertToClient(mode.result)
        context.mode = NoneMode()
        context.rawString = ""
        return .handled
    }
)

let kanaFixAndExecuteCommand = BoiledOneCommand(
    name: "KanaFixAndExecuteCommand",
    handler: {context in
        _ = kanaFixCommand.execute(context)
        return .reExecute
    }
)
