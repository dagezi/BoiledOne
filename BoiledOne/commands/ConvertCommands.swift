// Works on .raw 
// Convert raw string into Hiragana and setting up following conversion
class StartConvertCommand : BoiledOneCommand {
    static var inst: BoiledOneCommand = StartConvertCommand()
    var name = "StartConvertCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        let hira =
            context.romanConverter.convert(source: context.rawString)
        context.convedString = hira
        context.mode = .conv

        return .handled
    }
}
