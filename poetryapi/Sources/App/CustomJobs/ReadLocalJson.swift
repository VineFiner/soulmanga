//
//  ReadLocalJson.swift
//  App
//
//  Created by Finer  Vine on 2020/2/11.
//

import Vapor
import Jobs

// 本地读取，定时任务
struct ReadLocalJson: ScheduledJob {
    
    let name: String
    let app: Application
    static var files: [URL] = []
    
    init(name: String, app: Application) {
        self.name = name
        self.app = app
        
        // 调用函数
        readLocal()
    }
    //这里进行读取本地文件
    func readLocal() {
        let files = Data.fetchAllFiles()
        ReadLocalJson.files = files
        /*
        autoreleasepool {
            for fileURL in files {
                guard let data = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) else { return }
                guard let tangs = try? PoetryTang.loadFromFile(data) else { return }
                ReadLocalJson.decodedPoetryTangs.append(contentsOf: tangs)
            }
        }
        */
    }
    // 进行保存
    func saveJson() {
        
        if ReadLocalJson.files.isEmpty {
            return
        }
        let fileURL = ReadLocalJson.files.removeFirst()
        guard let data = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) else { return }
        guard let tangs = try? PoetryTang.loadFromFile(data) else { return }
        for tang in tangs {
            // 查询
            _ = PoetryTang.find(tang.id, on: app.db).flatMap { (findTang) -> EventLoopFuture<PoetryTang> in
                
                guard let realTang = findTang else {
                    // 查不到
                    return tang.save(on: self.app.db).map { tang }
                }
                return self.app.eventLoopGroup.future(realTang)
            }
        }
    }
    // 运行任务
    func run(context: JobContext) -> EventLoopFuture<Void> {
        context.logger.info("job \(self.name)!")
        // 进行存储
        saveJson()
        return context.eventLoop.makeSucceededFuture(())
    }
}
