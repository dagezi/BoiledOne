import Foundation
import InputMethodKit

enum BoiledOneInputMode: String {
    case none   // User never input anything
    case raw    // User has input some characters, but not converted
    case conv   // User started conversion, choosing candidate
}

class BoiledOneContext {
    let romanConverter = RomanConverter(defaultRomanTable)

    var mode: BoiledOneInputMode = BoiledOneInputMode.none
    var rawString: String = ""
    var convedString: String = "" // Temporary

    var prevCommand: BoiledOneCommand? = nil

    var inputString: String = ""
    var inputKeyCode: UInt16 = 0
    var inputModifiers: NSEvent.ModifierFlags = NSEvent.modifierFlags
    var inputClient: IMKTextInput?

    func insertToClient(_ s: String) {
        if (inputClient == nil) {
            NSLog("insertToClient: client is nil")
        } else {
            inputClient!.insertText(
                s, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        }
    }
}


enum BoiledOneCommandResult {
    case handled      // Handled
    case notHandled   // Not handled
    case reExecute    // Handled, but re execute with new state
    case through      // Handled, but through event to client
}

protocol BoiledOneCommand {
    static var inst: BoiledOneCommand { get }
    var name: String { get }
    func execute(_ : BoiledOneContext) -> BoiledOneCommandResult
}

