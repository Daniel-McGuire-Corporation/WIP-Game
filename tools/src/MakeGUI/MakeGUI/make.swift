import Foundation

func checkAndSetupMake() {
    let fileManager = FileManager.default
    guard let resourcesFolder = Bundle.main.resourceURL else {
        print("Unable to find resources directory.")
        return
    }
    
    let makeExecutable = resourcesFolder.appendingPathComponent("make")

    if fileManager.fileExists(atPath: makeExecutable.path) {
        return
    } else {
        compileMake()
    }
}

func compileMake() {
    let fileManager = FileManager.default
    guard let appSupportFolder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        print("Unable to find application support directory.")
        return
    }
    
    let makeSourcePath = appSupportFolder.appendingPathComponent("make.py")
    guard let resourcesFolder = Bundle.main.resourceURL else {
        print("Unable to find resources directory.")
        return
    }
    
    let compiledMakePath = appSupportFolder.appendingPathComponent("make")

    // Ensure the source file exists
    guard fileManager.fileExists(atPath: makeSourcePath.path) else {
        print("make.py not found in application support directory.")
        return
    }

    // Check if PyInstaller is installed
    if !checkCommand("pyinstaller") {
        if !checkCommand("pip") && !checkCommand("pip3") {
            if !checkCommand("python") && !checkCommand("python3") {
                if !checkCommand("brew") {
                    installBrew { success in
                        if success {
                            installPython { pythonInstalled in
                                if pythonInstalled {
                                    installPyInstaller()
                                } else {
                                    print("Python installation failed.")
                                }
                            }
                        } else {
                            print("Homebrew installation failed.")
                        }
                    }
                } else {
                    installPython { pythonInstalled in
                        if pythonInstalled {
                            installPyInstaller()
                        } else {
                            print("Python installation failed.")
                        }
                    }
                }
            } else {
                installPyInstaller()
            }
        } else {
            installPyInstaller()
        }
    } else {
        proceedToCompile(makeSourcePath: makeSourcePath, compiledMakePath: compiledMakePath, resourcesFolder: resourcesFolder)
    }
}

func checkCommand(_ command: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "command -v \(command) > /dev/null 2>&1"]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    } catch {
        return false
    }
}

func installBrew(completion: @escaping (Bool) -> Void) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        completion(process.terminationStatus == 0)
    } catch {
        completion(false)
    }
}

func installPython(completion: @escaping (Bool) -> Void) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "brew install python"]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        completion(process.terminationStatus == 0)
    } catch {
        completion(false)
    }
}

func installPyInstaller() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "python -m pip install pyinstaller"]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        // Proceed to compile after installing PyInstaller
        guard let appSupportFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
              let resourcesFolder = Bundle.main.resourceURL else {
            print("Unable to find directories.")
            return
        }
        let makeSourcePath = appSupportFolder.appendingPathComponent("make.py")
        let compiledMakePath = appSupportFolder.appendingPathComponent("make")
        proceedToCompile(makeSourcePath: makeSourcePath, compiledMakePath: compiledMakePath, resourcesFolder: resourcesFolder)
    } catch {
        print("PyInstaller installation failed.")
    }
}

func proceedToCompile(makeSourcePath: URL, compiledMakePath: URL, resourcesFolder: URL) {
    // Compile `make.py` with PyInstaller
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "pyinstaller --onefile \(makeSourcePath.path) --distpath \(resourcesFolder.path)"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
        
        // Move the compiled `make` to the Resources folder
        let compiledFileURL = resourcesFolder.appendingPathComponent("make")
        let fileManager = FileManager.default
        try fileManager.moveItem(at: compiledMakePath, to: compiledFileURL)
    } catch {
        print("Error compiling or moving make: \(error.localizedDescription)")
    }
}
