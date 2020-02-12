import Vapor

extension Data {
    static func fromFile(_ fileName: String,folder: String = "Resources/json") throws -> Data {
        let directory = DirectoryConfiguration.detect()
        let fileURL = URL(fileURLWithPath: directory.workingDirectory)
            .appendingPathComponent(folder, isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)

        return try Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe)
    }
    /// 获取所有文件
    static func fetchAllFiles(folder: String = "Resources/json") -> [URL] {
        var files: [URL] = []
        let fileBasedWorkDir: String?
        #if Xcode
        let file = #file
        if file.contains(".build") {
            // most dependencies are in `./.build/`
            fileBasedWorkDir = file.components(separatedBy: "/.build").first
        } else if file.contains("Packages") {
            // when editing a dependency, it is in `./Packages/`
            fileBasedWorkDir = file.components(separatedBy: "/Packages").first
        } else {
            // when dealing with current repository, file is in `./Sources/`
            fileBasedWorkDir = file.components(separatedBy: "/Sources").first
        }
        #else
        let directory = DirectoryConfiguration.detect()
        fileBasedWorkDir = directory.workingDirectory
        #endif
        if let fileBasedWorkDir = fileBasedWorkDir, let url = URL(string: fileBasedWorkDir)?.appendingPathComponent(folder, isDirectory: true) {
            let manager = FileManager.default
            // 类似上面的，对指定路径执行浅搜索，返回指定目录路径下的文件、子目录及符号链接的列表
            if let contentsOfURL = try? manager.contentsOfDirectory(at: url,includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                for filePath in contentsOfURL {
                    if filePath.absoluteString.hasSuffix("json") {
                        files.append(filePath)
                    }
                }
            }
        }
        return files
    }
}
