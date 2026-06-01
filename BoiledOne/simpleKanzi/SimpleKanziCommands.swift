private var dictionary = SimpleDictionary()

class SimpleKanziStartCommand : BoiledOneCommand {
    static let inst: BoiledOneCommand = SimpleKanziStartCommand()
    var name = "SimpleKanziStartCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        assert(context.mode == .raw)
        let hira =
            context.romanConverter.convert(source: context.rawString)
        let converter = SimpleKanziConverter(dictionary, hira)
        context.mode = .conv
        context.simpleKanziConverter = converter
        
        return .handled
    }
}

class SimpleKanziFixOneCommand: BoiledOneCommand {
    static let inst: BoiledOneCommand = SimpleKanziFixOneCommand()
    var name = "SimpleKanziFixOneCommand"

    func execute(_ context: BoiledOneContext) -> BoiledOneCommandResult {
        assert(context.mode == .conv)
        guard let converter = context.simpleKanziConverter else {
            return .handled
        }
        context.insertToClient(String(converter.getSelectedDest()))
        converter.fixOne()
        if converter.isEmpty() {
            context.mode = .raw
            context.simpleKanziConverter = .none
            context.rawString = ""
        }
        return .handled
    }
}