import Cocoa

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var feedbackWindowController: NSWindowController?

    @IBAction func openFeedbackWindow(_ sender: Any?) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateController(withIdentifier: "FeedbackWindowController") as? NSWindowController {
            self.feedbackWindowController = controller
            controller.showWindow(nil)
        }
    }
}
