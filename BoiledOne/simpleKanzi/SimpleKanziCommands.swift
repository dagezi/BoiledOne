private var dictionary = SimpleDictionary()

let simpleKanziStartCommand = BoiledOneCommand(
    name: "SimpleKanziStartCommand",
    handler: {context in
        assert(context.mode == .raw)
        let hira =
            context.romanConverter.convert(source: context.rawString)
        let converter = SimpleKanziConverter(dictionary, hira)
        context.mode = .conv
        context.simpleKanziConverter = converter
        
        return .handled
    },
)
let simpleKanziFixOneCommand = BoiledOneCommand(
    name: "SimpleKanziFixOneCommand",
    handler: {context in
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
)

let simpleKanziFixAllCommand = BoiledOneCommand(
    name: "SimpleKanziFixAllCommand",
    handler: {context in
        assert(context.mode == .conv)
        guard let converter = context.simpleKanziConverter else {
            return .handled
        }
        context.insertToClient("\(converter.getSelectedDest())\(converter.getUnconverted())")
        converter.fixAll()
        context.mode = .raw
        context.simpleKanziConverter = .none
        context.rawString = ""
        return .handled
    }
)

let simpleKanziSelectNextCommand = BoiledOneCommand(
    name: "SimpleKanziSelectNextCommand",
    handler: {context in
        assert(context.mode == .conv)
        guard let converter = context.simpleKanziConverter else {
            return .handled
        }
        converter.selectRelatively(diff: 1)
        return .handled
    }
)

let simpleKanziSelectPrevCommand = BoiledOneCommand(
    name: "SimpleKanziSelectPrevCommand",
    handler: {context in
        assert(context.mode == .conv)
        guard let converter = context.simpleKanziConverter else {
            return .handled
        }
        converter.selectRelatively(diff: -1)
        return .handled
    }
)
