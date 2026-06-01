// Works on .raw 
// Convert raw string into Hiragana and setting up following conversion
let startConvertCommand = BoiledOneCommand(
    name: "StartConvertCommand",
    handler: { context in
        let hira =
            context.romanConverter.convert(source: context.rawString)
        context.convedString = hira
        context.mode = .conv

        return .handled
    },
)
