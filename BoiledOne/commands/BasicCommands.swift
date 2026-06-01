import Foundation

let rawInsertSelfCommand = BoiledOneCommand(
    name: "InsertSelfCommand",
    handler: { context in
        context.rawString += context.inputString
        context.mode = .raw
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
            context.mode = .none
        }
        return .handled
    }
)

let nopCommand = BoiledOneCommand(
    name: "NopCommand",
    handler: { context in
        // Nothing to do
        return .handled
    }
)

// Works in .raw and .conv
let fixCommand = BoiledOneCommand(
    name: "FixCommand",
    handler: { context in
        var conved = context.mode == .raw ? context.rawString : context.convedString
        context.insertToClient(conved)
        context.convedString = ""
        context.rawString = ""
        context.mode = .none
        return .handled
    }
)

// Works in .raw and .conv
let fixAndExecuteCommand = BoiledOneCommand(
    name: "FixAndExecuteCommand",
    handler: { context in
        _ = fixCommand.execute(context)
        return .reExecute
    }
)

// Note: It doesn't work for Ctrl+M. Why?
let fixAndPassThruCommand = BoiledOneCommand(
    name: "FixAndPassThruCommand",

    handler: { context in
        _ = fixCommand.execute(context)
        return .through
    }
)
