import InputMethodKit
import OSLog


var server: IMKServer?
var candidatesWindow: IMKCandidates?

private let logger = Logger(subsystem: "BoiledOne", category: "App")

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("Starting IMKServer")
        server = IMKServer(name: "BoiledOne",
                           bundleIdentifier: Bundle.main.bundleIdentifier);
        logger.info("Started IMKServer")
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
    }
}
