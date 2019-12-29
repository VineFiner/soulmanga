import Vapor

extension Data {
    static func fromFile(_ fileName: String,folder: String = "Resources/json") throws -> Data {
        let directory = DirectoryConfiguration.detect()
        let fileURL = URL(fileURLWithPath: directory.workingDirectory)
            .appendingPathComponent(folder, isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)

        return try Data(contentsOf: fileURL)
    }
}
