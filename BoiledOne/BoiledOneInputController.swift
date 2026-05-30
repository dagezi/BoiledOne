import Cocoa
import InputMethodKit
import OSLog

let logger = Logger(subsystem: "BoiledOne", category: "Controller")

@objc(BoiledOneInputController)
class BoiledOneInputController: IMKInputController {
    var context = BoiledOneContext()
    var commandMap: CommandMap = CommandMap()

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {

        guard let event = event,
              event.type == .keyDown else { return false }

        logger.info("Boiled: str \(self.context.inputString) keyCode: \(self.context.inputKeyCode)")

        guard let client = sender as? IMKTextInput else {
            return false
        }

        context.inputClient = client
        context.inputString = event.characters ?? ""
        context.inputKeyCode = event.keyCode
        context.inputModifiers = event.modifierFlags

        var result: BoiledOneCommandResult = .reExecute
        let keyCode = context.inputKeyCode
        let modifiers = context.inputModifiers
        while (result == .reExecute) {
            result = .notHandled
            for entry in commandMap.map[context.mode]! {
                if keyCode == entry.keyCode, modifiers.intersection(entry.mask) == entry.modifiers {
                    logger.info("Command: \(entry.command.name) \(String(describing: modifiers))")
                    result = entry.command.execute(context)
                    context.prevCommand = entry.command
                    break
                }
            }
            if result == .notHandled {
                let mayFallback: BoiledOneCommand? = commandMap.fallbackCommands[context.mode]
                if let fallback = mayFallback {
                    result = fallback.execute(context)
                    context.prevCommand = fallback
                }
            }
        }
        context.inputClient = nil

        switch (context.mode) {
        case .none:
            client.setMarkedText(
                "",
                selectionRange: NSRange(location: 0, length: 0),
                replacementRange: .notFound,
            )

        case .raw:
            let stringToShow = context.rawString
            let attrs = mark(
                forStyle: kTSMHiliteSelectedConvertedText,
                at: NSRange(location: 0, length: stringToShow.utf16.count),
            )

            let marked = NSAttributedString(
                string: stringToShow,
                attributes: attrs as? [NSAttributedString.Key: Any],
            )

            client.setMarkedText(
                marked,
                selectionRange: NSRange(location: stringToShow.utf16.count, length: 0),
                replacementRange: .notFound,
            )
        case .conv:
            if let converter = context.simpleKanziConverter {
                let converted = converter.getSelectedDest()
                let unconverted = converter.getUnconverted()

                let stringToShow: String = "\(converted)\(unconverted)"
                let markedString = NSMutableAttributedString(string: stringToShow)

                markedString.addAttributes(
                    mark(forStyle: kTSMHiliteSelectedConvertedText, at: .notFound) as! [NSAttributedString.Key: Any],
                    range: NSRange(location: 0, length: converted.utf16.count),
                )
                markedString.addAttributes(
                    mark(forStyle: kTSMHiliteConvertedText, at: .notFound) as! [NSAttributedString.Key: Any],
                    range: NSRange(location: converted.utf16.count, length: unconverted.utf16.count),
                )

                client.setMarkedText(
                    markedString,
                    selectionRange: NSRange(location: stringToShow.utf16.count, length: 0),
                    replacementRange: NSRange(location: NSNotFound, length: 0),
                )
            }
        }
        return result == .handled
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        // Return an empty list; no candidate window for now.
        return []
    }

    // ── Menu Items (optional) ──────────────────────────────────────────────

    override func menu() -> NSMenu! {
        let menu = NSMenu()
        let item = NSMenuItem(
            title: "About BoiledOne",
            action: #selector(aboutAction),
            keyEquivalent: ""
        )
        item.target = self
        menu.addItem(item)
        return menu
    }

    @objc private func aboutAction() {
        NSLog("BoiledOne v1.0 — Hello World IME")
    }
}
