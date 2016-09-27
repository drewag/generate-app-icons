import Foundation

struct IconSpec {
    enum Multiple {
        case single, double, triple
    }

    let baseSize: Float
    let multiples: [Multiple]
}

let iconSpecs: [IconSpec] = [
    IconSpec(baseSize: 20, multiples: [.single, .double, .triple]),
    IconSpec(baseSize: 29, multiples: [.single, .double, .triple]),
    IconSpec(baseSize: 40, multiples: [.single, .double, .triple]),
    IconSpec(baseSize: 50, multiples: [.single, .double]),
    IconSpec(baseSize: 57, multiples: [.single, .double]),
    IconSpec(baseSize: 60, multiples: [.double, .triple]),
    IconSpec(baseSize: 72, multiples: [.single, .double]),
    IconSpec(baseSize: 76, multiples: [.single, .double]),
    IconSpec(baseSize: 83.5, multiples: [.double]),
]

struct ImageConverter {
    let originalPath: String
    let numberFormatter = NumberFormatter()

    private var destinationDirectory: String {
        let URL = NSURL(fileURLWithPath: self.originalPath)
        return URL.deletingLastPathComponent!.relativePath
    }

    init(originalPath: String) {
        self.originalPath = originalPath
        self.numberFormatter.minimumFractionDigits = 0
        self.numberFormatter.maximumFractionDigits = 5
    }

    func duplicateImage(to spec: IconSpec) {
        for multiple in spec.multiples {
            let sizeString = self.numberFormatter.string(from: NSNumber(value: spec.baseSize))!

            switch multiple {
            case .single:
                duplicateImage(toSize: spec.baseSize, withName: "icon\(sizeString).png")
            case .double:
                duplicateImage(toSize: spec.baseSize * 2, withName: "icon\(sizeString)@2x.png")
            case .triple:
                duplicateImage(toSize: spec.baseSize * 3, withName: "icon\(sizeString)@3x.png")
            }
        }
    }

    private func duplicateImage(toSize size: Float, withName name: String) {
        let command = ShellCommand([
            "convert",
            self.originalPath,
            "-resize",
            "\(Int(size))x\(Int(size))",
            self.join(basePath: self.destinationDirectory, to: name)
        ])

        let output = command.execute()
        guard output.isEmpty else {
            print("Problem converting to \(size) to name \(name):\n\(output)")
            return
        }
    }

    private func join(basePath: String, to: String) -> String {
        let URL = NSURL(fileURLWithPath: basePath)
        return URL.appendingPathComponent(to)!.relativePath
    }
}

guard CommandLine.arguments.count > 1 else {
    print("Usage: \(CommandLine.arguments[0]) <path_to_1024x1024_image>")
    exit(1)
}

let filePath = CommandLine.arguments[1]

let converter = ImageConverter(originalPath: filePath)
for spec in iconSpecs {
    converter.duplicateImage(to: spec)
}
