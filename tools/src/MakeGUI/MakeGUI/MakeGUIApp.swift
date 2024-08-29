import SwiftUI
import AppKit

@main
struct MakeGUIApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    @StateObject private var aboutWindowController = AboutWindowController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
                .onReceive(NotificationCenter.default.publisher(for: .showAboutWindowNotification)) { _ in
                    aboutWindowController.showAboutWindow(appEnvironment: appEnvironment)
                }
        }
        .commands {
            MenuCommands(appEnvironment: appEnvironment)
        }
    }
}

class AboutWindowController: ObservableObject {
    private var aboutWindow: NSWindow?

    func showAboutWindow(appEnvironment: AppEnvironment) {
        if aboutWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 445, height: 645),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "About MakeGUI"
            window.contentView = NSHostingView(rootView: AboutView().environmentObject(appEnvironment))
            window.center()
            window.isReleasedWhenClosed = false
            aboutWindow = window
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
}
