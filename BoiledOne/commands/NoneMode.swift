class NoneMode : BoiledOneMode {
    override init() {
        super.init()

        for keyCode: Int in BoiledOneMode.selfInsertKeys {
            commandMap.append(CommandEntry(keyCode, [], insertSelfAndRawModeCommand))
        }
        fallbackCommand = passThruCommand
    }
}

private let insertSelfAndRawModeCommand = BoiledOneCommand(
    name: "InsertSelfCommand",
    handler: { context in
        context.mode = RawMode()
        return .reExecute
    }
)
