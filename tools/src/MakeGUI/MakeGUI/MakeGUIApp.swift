import SwiftUI
import AppKit

@main
struct MakeGUIApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    @StateObject private var aboutWindowController = AboutWindowController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400, height: 245)
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
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 355),
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
