import Foundation

class RawInsertSelfCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = RawInsertSelfCommand()
    var name = "InsertSelfCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        context.rawString += context.inputString
        context.mode = .raw
        return .handled
    }
}

class RawBackSpaceCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = RawBackSpaceCommand()

    var name: String = "RawBackSpaceCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        if !context.rawString.isEmpty {
            context.rawString.removeLast()
        }
        if (context.rawString.isEmpty) {
            context.mode = .none
        }
        return .handled
    }
}

class NopCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = NopCommand()
    var name = "NopCommand"

    func execute(_: BoiledOneContext) -> BoiledOneCommandResult {
        // Nothing to do
        return .handled
    }
}

// Works in .raw and .conv
class FixCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = FixCommand()
    var name: String = "FixCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        var conved = context.rawString
        context.insertToClient(conved)
        context.convedString = ""
        context.rawString = ""
        context.mode = .none
        return .handled
    }
}

// Works in .raw and .conv
class FixAndExecuteCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = FixAndExecuteCommand()
    var name: String = "FixAndExecuteCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        _ = FixCommand.inst.execute(context)
        return .reExecute
    }
}

// Note: It doesn't work for Ctrl+M. Why?
class FixAndPassThruCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = FixAndPassThruCommand()
    var name: String = "FixAndPassThruCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        _ = FixCommand.inst.execute(context)
        return .through
    }
}
