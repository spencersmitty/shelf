import SwiftUI

@main
struct ShelfApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(macOS)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Shelf") { }
            }
            CommandGroup(after: .appInfo) {
                Button("Settings…") { }
            }
            CommandGroup(after: .help) {
                Button("Submit Feedback…") {
                    appDelegate.openFeedbackWindow(nil)
                }
            }
        }
#endif
    }
}
