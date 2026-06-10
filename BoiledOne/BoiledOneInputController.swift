import Cocoa
import InputMethodKit
import OSLog

private let logger = Logger(subsystem: "BoiledOne", category: "Controller")

@objc(BoiledOneInputController)
class BoiledOneInputController: IMKInputController {
    var context: BoiledOneContext = BoiledOneContext()

    override init(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        super.init(server: server, delegate: delegate, client: inputClient)

        logger.info("Initialized.")
    }

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
            for entry in context.mode.commandMap {
                if keyCode == entry.keyCode, modifiers.intersection(entry.mask) == entry.modifiers {
                    logger.info("Command: \(entry.command.name) \(String(describing: modifiers))")
                    result = entry.command.execute(context)
                    context.prevCommand = entry.command
                    break
                }
            }
            if result == .notHandled {
                let fallback = context.mode.fallbackCommand
                logger.info("Command: \(fallback.name) \(String(describing: modifiers))")
                result = fallback.execute(context)
                context.prevCommand = fallback
            }
        }
        context.inputClient = nil

        let stringsWithAttr = context.mode.getShowString(context)
        let stringToShow = stringsWithAttr.map { $0.0 } .joined()
        let markedString = NSMutableAttributedString(string: stringToShow)
        var index = 0
        for (s, attr) in stringsWithAttr {
            let mark = mark(forStyle: attr, at: .notFound) as! [NSAttributedString.Key: Any]
            let len = s.utf16.count
            markedString.addAttributes(mark, range: NSRange(location: index, length: len))
            index += len
        }
        client.setMarkedText(
            markedString,
            selectionRange: NSRange(location: stringToShow.utf16.count, length: 0),
            replacementRange: .notFound,
        )
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
