import Carbon.HIToolbox

class RawMode : BoiledOneMode {
    var insertIndex: String.Index

    init(_ context: BoiledOneContext) {
        insertIndex = context.rawString.endIndex
        super.init()
        
        commandMap = [
            CommandEntry(kVK_ANSI_B, [.control] , moveLeftCommand),
            CommandEntry(kVK_ANSI_F, [.control] , moveRightCommand),
            CommandEntry(kVK_ANSI_H, [.control] , rawBackSpaceCommand),
            CommandEntry(kVK_ANSI_J, [.control], simpleKanziStartCommand),
            CommandEntry(kVK_ANSI_K, [.control], kanaStartCommand),
            CommandEntry(kVK_ANSI_L, [.control], fixCommand),
            CommandEntry(kVK_ANSI_M, [.control], fixAndPassThruCommand),
            CommandEntry(kVK_Tab, [], fixAndPassThruCommand),
            CommandEntry(kVK_Return, [], fixAndPassThruCommand),
            CommandEntry(kVK_Space, [], fixAndPassThruCommand),
            CommandEntry(kVK_LeftArrow, [] , moveLeftCommand),
            CommandEntry(kVK_RightArrow, [] , moveRightCommand),
        ]

        fallbackCommand = fixAndExecuteCommand

        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], rawInsertSelfCommand))
        }
    }

    override func getShowString(_ context: BoiledOneContext) -> [(Substring, Int)] {
        return [
            (context.rawString[..<insertIndex], -1),
            (context.rawString[insertIndex..<insertIndex], kTSMHiliteCaretPosition),
            (context.rawString[insertIndex...], -1),
        ]
    }
}

let rawInsertSelfCommand = BoiledOneCommand(
    name: "InsertSelfCommand",
    handler: { context in
        guard let mode: RawMode = context.mode as? RawMode else { return .handled }

        context.rawString.insert(contentsOf: context.inputString, at: mode.insertIndex)
        mode.insertIndex = context.rawString.index(
            mode.insertIndex, offsetBy: context.inputString.count)
        return .handled
    },
)

let rawBackSpaceCommand = BoiledOneCommand(
    name: "RawBackSpaceCommand",
    handler: { context in
        guard let mode: RawMode = context.mode as? RawMode else { return .handled }

        if !context.rawString.isEmpty && mode.insertIndex != context.rawString.startIndex {
            mode.insertIndex = context.rawString.index(before: mode.insertIndex)
            context.rawString.remove(at: mode.insertIndex)
        }
        if (context.rawString.isEmpty) {
            context.mode = NoneMode()
        }
        return .handled
    },
)

private let moveLeftCommand = BoiledOneCommand(
    name: "MoveLeftCommand", 
    handler: { context in
        guard let mode: RawMode = context.mode as? RawMode else { return .handled }
        if mode.insertIndex != context.rawString.startIndex {
            mode.insertIndex = context.rawString.index(before: mode.insertIndex)            
        }
        return .handled
    },
)

private let moveRightCommand = BoiledOneCommand(
    name: "MoveRightCommand", 
    handler: { context in
        guard let mode: RawMode = context.mode as? RawMode else { return .handled }
        if mode.insertIndex != context.rawString.endIndex {
            mode.insertIndex = context.rawString.index(after: mode.insertIndex)            
        }
        return .handled
    },
)


private let fixCommand = BoiledOneCommand(
    name: "FixCommand",
    handler: { context in
        context.insertToClient(context.rawString)
        context.rawString = ""
        context.mode = NoneMode()
        return .handled
    },
)

private let fixAndExecuteCommand: BoiledOneCommand = BoiledOneCommand(
    name: "FixAndExecuteCommand",
    handler: { context in
        _ = fixCommand.execute(context)
        return .reExecute
    },
)

// Note: It doesn't work for Ctrl+M. Why?
private let fixAndPassThruCommand = BoiledOneCommand(
    name: "FixAndPassThruCommand",

    handler: { context in
        _ = fixCommand.execute(context)
        return .through
    },
)

let cancelCommand = BoiledOneCommand(
    name: "CancelCommand", 
    handler: {context in 
        // TODO: In case part of the src was fixed, recreate rawString
        context.mode = RawMode(context)
        return .handled
    },
)

let cancelAndExecuteCommand = BoiledOneCommand(
    name: "CancelAndExecuteCommand", 
    handler: { context in
        // TODO: In case part of the src was fixed, recreate rawString
        context.mode = RawMode(context)
        return .reExecute
    },
)
