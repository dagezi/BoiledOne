import Carbon.HIToolbox

class RawMode : BoiledOneMode {
    override init() {
        super.init()
        
        commandMap = [
            CommandEntry(kVK_ANSI_H, [.control] , rawBackSpaceCommand),
            CommandEntry(kVK_ANSI_K, [.control], kanaStartCommand),
            CommandEntry(kVK_ANSI_L, [.control], fixCommand),
            CommandEntry(kVK_ANSI_M, [.control], fixAndPassThruCommand),
            CommandEntry(kVK_Tab, [], fixAndPassThruCommand),
            CommandEntry(kVK_Return, [], fixAndPassThruCommand),
            CommandEntry(kVK_Space, [], fixAndPassThruCommand),
            CommandEntry(kVK_ANSI_J, [.control], simpleKanziStartCommand),
        ]

        fallbackCommand = fixAndExecuteCommand

        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], rawInsertSelfCommand))
        }
    }

    override func getShowString(_ context: BoiledOneContext) -> [(Substring, Int)] {
        return [(context.rawString[...], kTSMHiliteSelectedConvertedText)]
    }
}

let rawInsertSelfCommand = BoiledOneCommand(
    name: "InsertSelfCommand",
    handler: { context in
        context.rawString += context.inputString
        return .handled
    }
)

let rawBackSpaceCommand = BoiledOneCommand(
    name: "RawBackSpaceCommand",
    handler: { context in
        if !context.rawString.isEmpty {
            context.rawString.removeLast()
        }
        if (context.rawString.isEmpty) {
            context.mode = NoneMode()
        }
        return .handled
    }
)

private let fixCommand = BoiledOneCommand(
    name: "FixCommand",
    handler: { context in
        context.insertToClient(context.rawString)
        context.rawString = ""
        context.mode = NoneMode()
        return .handled
    }
)

private let fixAndExecuteCommand: BoiledOneCommand = BoiledOneCommand(
    name: "FixAndExecuteCommand",
    handler: { context in
        _ = fixCommand.execute(context)
        return .reExecute
    }
)

// Note: It doesn't work for Ctrl+M. Why?
private let fixAndPassThruCommand = BoiledOneCommand(
    name: "FixAndPassThruCommand",

    handler: { context in
        _ = fixCommand.execute(context)
        return .through
    }
)

let cancelCommand = BoiledOneCommand(
    name: "CancelCommand", 
    handler: {context in 
        // TODO: In case part of the src was fixed, recreate rawString
        context.mode = RawMode()
        return .handled
    },
)

let cancelAndExecuteCommand = BoiledOneCommand(
    name: "CancelAndExecuteCommand", 
    handler: { context in
        // TODO: In case part of the src was fixed, recreate rawString
        context.mode = RawMode()
        return .reExecute
    },
)
