import SwiftUI

struct ContentView: View {
    @State private var debugMode = false
    @State private var clean = false
    @State private var selectedTarget: String = "Select Target"
    @State private var outputText: String = ""
    @State private var showCommand = false

    let buildTargets = ["-all", "-tools", "-game", "-editor", "-viewer", "-tweaker"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("untitledgame Build and Setup Program")
                .font(.headline)
                .padding(.bottom)

            HStack {
                Toggle("Debug Mode", isOn: $debugMode)
                    .padding(.trailing)

                Toggle("Clean", isOn: $clean)
            }
            .padding(.bottom)

            Text("Targets:")
                .font(.subheadline)
                

            Menu {
                ForEach(buildTargets, id: \.self) { target in
                    Button(target) {
                        selectedTarget = target
                    }
                }
            } label: {
                Text(selectedTarget)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }
            .padding(.bottom)

            Button("Run Command") {
                runMakeCommand()
            }
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(5)
            .frame(maxWidth: 208, maxHeight: 50) // Make button 50 less wide than the button width, DO NOT TOUCH 'maxHeight'!
            .fixedSize()
            .frame(height: 67)
            .padding(.top)

            if showCommand {
                Text("Command:")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: .constant(generateCommand()))
                    .frame(height: 100)
                    .border(Color.gray)
                    .padding(.bottom)

                Text("Output:")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(outputText)
                        .padding()
                }
                .frame(maxHeight: 300) // Set the height of the output box
            } else {
                TextField("Output", text: .constant(outputText))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
            }

            Toggle("Show Command", isOn: $showCommand)
                .padding(.top)
        }
        .padding()
    }

    func runMakeCommand() {
        var arguments: [String] = []

        if clean && selectedTarget != "Select Target" {
            arguments.append("-clean")
        }

        if selectedTarget == "-setupengine" {
            setupEngine()
            return
        }

        if debugMode {
            arguments.append("-debug")
        }

        if selectedTarget != "Select Target" && selectedTarget != "-setupengine" {
            arguments.append("-compile")
            arguments.append(selectedTarget)
        }

        let command = "../make"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "\(command) \(arguments.joined(separator: " "))"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            outputText = String(decoding: data, as: UTF8.self)
        } catch {
            outputText = "Error running command: \(error.localizedDescription)"
        }
    }

    private func setupEngine() {
        let command = "../make -setupengine"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            outputText = String(decoding: data, as: UTF8.self)
        } catch {
            outputText = "Error running setup engine: \(error.localizedDescription)"
        }
    }

    private func generateCommand() -> String {
        if selectedTarget == "-setupengine" {
            return "../make -setupengine"
        }

        var command = "../make"
        if debugMode { command += " -debug" }
        if clean { command += " -clean" }
        if selectedTarget != "Select Target" && selectedTarget != "-setupengine" {
            command += " -compile \(selectedTarget)"
        }
        return command
    }
}

struct Checkbox: View {
    @Binding var isChecked: Bool
    let checkmark: () -> Void
    let removeCheckmark: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                Text(" ")
            }
            .foregroundColor(.primary)
        }
    }

    private func toggle() {
        if isChecked {
            removeCheckmark()
        } else {
            checkmark()
        }
    }
}

#Preview {
    ContentView()
}
