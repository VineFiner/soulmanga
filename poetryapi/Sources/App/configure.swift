import Fluent
import FluentSQLiteDriver
import Queues
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    // Configure migrations
    app.migrations.add(CreateTodo())
    app.migrations.add(PoetryTang())
    
    app.migrations.add(BookInfo())
    app.migrations.add(BookChapter())
    
    // Configure jobs
    app.queues.use(custom: JobsNormalDriver())
    app.queues.add(Email(app: app))
        
    // 定时任务
    app.queues.schedule(SendMessage(name: "minutely at 1", app: app))
        .minutely()
        .at(1)
    
    // 添加定时读取任务
    /*
    app.jobs.schedule(ReadLocalJson(name: "read local json", app: app))
        .minutely()
        .at(1)
    */
    // register routes
    try routes(app)
}

// 定时任务
struct SendMessage: ScheduledJob {
    
    let name: String
    let app: Application
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        context.logger.info("job \(self.name)!")
        _ = app.queues.queue.dispatch(Email.self, Email.Message.init(to: "tanner@vapor.codes"))
        return context.eventLoop.makeSucceededFuture(())
    }
}
