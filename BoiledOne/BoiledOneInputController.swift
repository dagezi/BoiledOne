import Cocoa
import InputMethodKit
import OSLog

let logger = Logger(subsystem: "BoiledOne", category: "Controller")
@objc(BoiledOneInputController)
class BoiledOneInputController: IMKInputController {
    var context = BoiledOneContext()

    // ── State ──────────────────────────────────────────────────────────────
    private var composingBuffer = ""

    // ── Key Input ──────────────────────────────────────────────────────────

    /// Called for every keydown while your IME is active.
    /// Return true if you handled the event; false to pass it through.
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
        context.inputModifier = event.modifierFlags

        if (context.inputString == "!") {
            return true
        }
        return false
    }

    // ── Composition Display ────────────────────────────────────────────────

    /// Sends the current buffer to the client app as "marked text"
    /// (underlined, not yet committed). This is the preedit/composition string.
    private func updateComposingText(_ client: IMKTextInput) {
        if composingBuffer.isEmpty {
            // Clear the marked text region
            client.setMarkedText(
                "",
                selectionRange: NSRange(location: 0, length: 0),
                replacementRange: NSRange(location: NSNotFound, length: 0)
            )
        } else {
            // Show composing buffer as underlined marked text
            let attrs = mark(
                forStyle: kTSMHiliteSelectedConvertedText,
                at: NSRange(location: 0, length: composingBuffer.utf16.count)
            )

            let marked = NSAttributedString(
                string: composingBuffer,
                attributes: attrs as? [NSAttributedString.Key: Any]
            )

            client.setMarkedText(
                marked,
                selectionRange: NSRange(
                    location: composingBuffer.utf16.count,
                    length: 0
                ),
                replacementRange: NSRange(location: NSNotFound, length: 0)
            )
        }
    }

    // ── Commit ─────────────────────────────────────────────────────────────

    /// Called by IMK when composition should be finalized (focus change, etc.)
    override func commitComposition(_ sender: Any!) {
        guard !composingBuffer.isEmpty else { return }

        guard let client = sender as? IMKTextInput else { return }

        // This is where you'd run kana→kanji conversion.
        // For Hello World, we just commit raw text.
        client.insertText(
            composingBuffer,
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )

        composingBuffer = ""
    }

    // ── Candidates (optional stub) ─────────────────────────────────────────

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
