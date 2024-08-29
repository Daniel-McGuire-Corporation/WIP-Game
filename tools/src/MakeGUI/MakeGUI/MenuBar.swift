import SwiftUI

struct MenuCommands: Commands {
    @ObservedObject var appEnvironment: AppEnvironment

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About MakeGUI") {
                // Notify to open a new window
                NotificationCenter.default.post(name: .showAboutWindowNotification, object: nil)
            }
            .keyboardShortcut("i", modifiers: [.command])
        }
        
        CommandMenu("Build") {
            Button("Build All") {
                // Implement the build all functionality
                print("Build All clicked")
            }
            .keyboardShortcut("b", modifiers: [.command, .option])
            Button("Build Game") {
                // Implement the build game functionality
                print("Build Game clicked")
            }
            .keyboardShortcut("g", modifiers: [.command, .option])
            Button("Build Tools") {
                // Implement the build tools functionality
                print("Build Tools clicked")
            }
            .keyboardShortcut("t", modifiers: [.command, .option])
        }
    }
}
