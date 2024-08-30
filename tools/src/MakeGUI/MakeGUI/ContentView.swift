import SwiftUI

struct ContentView: View {
    @State private var debugMode = false
    @State private var runMode = false
    @State private var clean = false
    @State private var selectedTarget: String = "Select Target"
    @State private var outputText: String = ""
    @State private var showCommand = false

    let buildTargets = ["-all", "-tools", "-game", "-editor", "-viewer", "-tweaker"]

    var body: some View {
        VStack(alignment: .center) {
            Text("untitled-game Make Command GUI (WIP)")
                .padding(.bottom)
            HStack {
                Toggle("Debug", isOn: $debugMode)
                    .padding(.trailing)
                
                Toggle("Run", isOn: $runMode)
                    .padding(.trailing)
                
                Toggle("Clean (Must be used alone!)", isOn: $clean)
            }
            Text("Targets")
                .font(.headline)
                .padding(.top)
                
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
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
            .frame(maxWidth: 208, maxHeight: 50)
            .fixedSize()
            .frame(height: 67)
            .padding(.top)

            if showCommand {
                Text("Command")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: .constant(generateCommand()))
                    .frame(height: 100)
                    .border(Color.gray)
                    .padding(.bottom)

                Text("Output")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(outputText)
                        .padding()
                }
                .frame(maxHeight: 300)
            } else {
                Text("Command")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: .constant(generateCommand()))
                    .frame(height: 20)
                    .border(Color.clear)
                    .cornerRadius(4)
                    .padding(.bottom)
            }
        }
        TextField("Output", text: .constant(outputText))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom)
        .padding()
        .onAppear(perform: checkAndSetupMake)
        Toggle("Advanced", isOn: $showCommand)
            .padding(.top)
        }
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
        
        if runMode {
            arguments.append("-run")
        }

        if selectedTarget != "Select Target" && selectedTarget != "-setupengine" {
            arguments.append("-compile")
            arguments.append(selectedTarget)
        }

        let command = Bundle.main.path(forResource: "make", ofType: "") ?? ""
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
        let command = "../../make -setupengine"
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

        var command = "$ ./make"
        if debugMode { command += " -debug" }
        if clean { command += " -clean" }
        if runMode { command += " -run"}
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
        .frame(width: 400, height: 245)
}
