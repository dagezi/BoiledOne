import SwiftUI
import InputMethodKit
import OSLog

var server: IMKServer?

private let logger = Logger(subsystem: "BoiledOne", category: "App")
@main
struct BoiledOneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("Starting IMKServer")
        server = IMKServer(name: "BoiledOne",
                           bundleIdentifier: Bundle.main.bundleIdentifier);
        logger.info("Started IMKServer")
    }
}
