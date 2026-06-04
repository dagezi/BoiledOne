import Carbon
class KanaMode : BoiledOneMode {
    let hira: String

    init(_ context: BoiledOneContext) {
        self.hira = romanConverter.convert(source: context.rawString)

        super.init()

        commandMap = [
            CommandEntry(kVK_ANSI_L, [.control], kanaFixCommand),  
        ]
        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], kanaFixAndExecuteCommand))
        }
        fallbackCommand = nopCommand
    }

    override func getShowString(_ context: BoiledOneContext) -> [(Substring, Int)] {
        return [
            (hira[...], kTSMHiliteSelectedConvertedText),
        ]
    }
}

let kanaStartCommand = BoiledOneCommand(
    name: "KanaStartCommand",
    handler: {context in
        context.mode = KanaMode(context)
        return .handled
    }
)

let kanaFixCommand = BoiledOneCommand(
    name: "KanaFixCommand", 
    handler: {context in
        guard let mode = context.mode as? KanaMode else {
            return .handled
        }
        context.insertToClient(mode.hira)
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
