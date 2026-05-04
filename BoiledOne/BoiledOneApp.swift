import SwiftUI
import InputMethodKit

var server: IMKServer?

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
        server = IMKServer(name: "BoiledOne",
                           bundleIdentifier: Bundle.main.bundleIdentifier);
    }
}
