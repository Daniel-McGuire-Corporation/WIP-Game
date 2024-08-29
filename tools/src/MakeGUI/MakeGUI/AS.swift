import SwiftUI
import Combine
import Foundation

extension Notification.Name {
    static let showAboutWindowNotification = Notification.Name("showAboutWindowNotification")
}

class AppEnvironment: ObservableObject {
    @Published var output: [String] = []
    @Published var showAboutWindow: Bool = false {
        didSet {
            if showAboutWindow {
                NotificationCenter.default.post(name: .showAboutWindowNotification, object: nil)
            }
        }
    }

    func runCommand(_ command: String) {
        // Implement command execution and handle output
        // For now, simulate command execution
        output.append("Running command: \(command)")
    }
}
