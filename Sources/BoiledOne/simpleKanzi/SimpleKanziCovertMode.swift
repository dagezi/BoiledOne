import Carbon.HIToolbox

private var dictionary = SimpleDictionary()

class SimpleKanziConvertMode: BoiledOneMode {
    let converter: SimpleKanziConverter
    let hira: String
    let hiraToRomaMap: [Int:Int]
    var fixedHiraCount = 0
    var fixedRomaCount = 0

    init(_ context: BoiledOneContext) {
        (self.hira, self.hiraToRomaMap) = romanConverter.convert(source: context.rawString)
        self.converter = SimpleKanziConverter(dictionary, hira)

        super.init()

        commandMap = [
            CommandEntry(kVK_ANSI_F, [.control], simpleKanziFixOneCommand),  
            CommandEntry(kVK_ANSI_G, [.control], cancelCommand),  
            CommandEntry(kVK_ANSI_H, [.control], cancelCommand),  
            CommandEntry(kVK_ANSI_I, [.control], simpleKanziShrinkCommand),
            CommandEntry(kVK_ANSI_J, [.control], simpleKanziSelectNextCommand),
            CommandEntry(kVK_ANSI_K, [.control], simpleKanziKataHiraCommand),
            CommandEntry(kVK_ANSI_L, [.control], simpleKanziFixAllCommand),  
            CommandEntry(kVK_ANSI_M, [.control], simpleKanziFixAndExecuteCommand),  
            CommandEntry(kVK_ANSI_N, [.control], simpleKanziSelectNextCommand),
            CommandEntry(kVK_ANSI_O, [.control], simpleKanziExtendCommand),
            CommandEntry(kVK_ANSI_P, [.control], simpleKanziSelectPrevCommand),
            CommandEntry(kVK_Escape, [], cancelCommand),
            CommandEntry(kVK_Return, [], simpleKanziFixAllCommand),  
        ]
        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], simpleKanziFixAndExecuteCommand))
        }
        fallbackCommand = simpleKanziFixAndExecuteCommand
    }

    override func getShowString(_ context: BoiledOneContext) -> [(Substring, Int)] {
        return [
            (converter.getSelectedDest(), kTSMHiliteSelectedConvertedText),
            (converter.getUnconverted(), kTSMHiliteConvertedText),
        ]        
    }

    override func deactivate(_ context: BoiledOneContext) {
        _ = simpleKanziFixAllCommand.handler(context)
    }
}

let simpleKanziStartCommand = BoiledOneCommand(
    name: "SimpleKanziStartCommand",
    handler: {context in
        context.mode = SimpleKanziConvertMode(context)
        
        return .handled
    },
)

let simpleKanziStartWithKanaCommand = BoiledOneCommand(
    name: "SimpleKanziStartWithKanaCommand",
    handler: {context in
        let mode: SimpleKanziConvertMode = SimpleKanziConvertMode(context)
        mode.converter.selectKanaAll()
        context.mode = mode

        return .handled
    },
)

let simpleKanziFixAllCommand = BoiledOneCommand(
    name: "SimpleKanziFixAllCommand",
    handler: {context in
        guard let mode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        context.insertToClient("\(mode.converter.getSelectedDest())\(mode.converter.getUnconverted())")
        mode.converter.fixAll()
        context.mode = NoneMode()
        context.rawString = ""
        return .handled
    },
)

let simpleKanziFixOneCommand = BoiledOneCommand(
    name: "SimpleKanziFixOneCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        context.insertToClient(String(mode.converter.getSelectedDest()))
        let consumedHira = mode.converter.getSelectedSrc()    
        mode.fixedHiraCount += consumedHira.count    
        if let fixedRoma = mode.hiraToRomaMap[mode.fixedHiraCount] {
            let consumedRoma = fixedRoma - mode.fixedRomaCount
            let newStartIx = context.rawString.index(context.rawString.startIndex, offsetBy: consumedRoma)
            mode.fixedRomaCount = fixedRoma
            context.rawString = String(context.rawString[newStartIx...])
        } else {
            // TODO: "tya" → "ちゃ" → "地|ゃ" のようなときにおこる。これをキャンセルしたら "xya" がいい?
        }

        mode.converter.fixOne()
        if mode.converter.isEmpty() {
            context.mode = NoneMode()
            context.rawString = ""
        }
        return .handled
    },
)

let simpleKanziFixAndExecuteCommand: BoiledOneCommand = BoiledOneCommand(
    name: "FixAndExecuteCommand",
    handler: { context in
        _ = simpleKanziFixAllCommand.execute(context)
        return .reExecute
    },
)

let simpleKanziSelectNextCommand = BoiledOneCommand(
    name: "SimpleKanziSelectNextCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        mode.converter.selectRelatively(diff: 1)
        return .handled
    },
)

let simpleKanziSelectPrevCommand = BoiledOneCommand(
    name: "SimpleKanziSelectPrevCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        mode.converter.selectRelatively(diff: -1)
        return .handled
    },
)

let simpleKanziKataHiraCommand = BoiledOneCommand(
    name: "SimpleKanziKataHiraCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        mode.converter.selectKanaOrShrink()
        return .handled
    },
)

let simpleKanziShrinkCommand = BoiledOneCommand(
    name: "SimpleKanziShrinkCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        mode.converter.extendCandidate(diff: -1)
        return .handled
    },
)

let simpleKanziExtendCommand = BoiledOneCommand(
    name: "SimpleKanziExtendCommand",
    handler: {context in
        guard let mode: SimpleKanziConvertMode = context.mode as? SimpleKanziConvertMode  else {
            return .handled
        }
        mode.converter.extendCandidate(diff: 1)
        return .handled
    },
)
