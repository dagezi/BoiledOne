import AppKit
import InputMethodKit

// UIがないと applicationDidFinishLaunchingが呼ばれなかったので明示的に NSApplicationMainを呼び出す。
// TODO: もっと簡潔な方法はないか?

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
