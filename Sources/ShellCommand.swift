import Foundation

public struct ShellCommand: CustomStringConvertible {
    let command: [String]

    public init(_ command: [String]) {
        self.command = command
    }

    public func execute() -> String {
        let process = Process()

        process.launchPath = "/usr/bin/env"
        process.arguments = self.command

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        process.launch()

        let outputString = String(data: outputPipe.fileHandleForReading.availableData, encoding: .utf8) ?? ""
        return outputString
    }

    public var description: String {
        return self.command.joined(separator: " ")
    }
}
