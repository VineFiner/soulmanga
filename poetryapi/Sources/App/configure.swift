import Fluent
import FluentSQLiteDriver
import Vapor
import Jobs

// Called before your application initializes.
func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure SQLite database
    app.databases.use(.sqlite(file: "db.sqlite"), as: .sqlite)

    // Configure migrations
    app.migrations.add(CreateTodo())
    app.migrations.add(PoetryTang())
    
    // Configure jobs
    app.jobs.use(custom: JobsNormalDriver())
    app.jobs.add(Email())
    
    
    app.jobs.schedule(SendMessage(name: "minutely at 1", app: app))
        .minutely()
        .at(1)
    
    // routes
    try routes(app)
}
// 定时任务
struct SendMessage: ScheduledJob {
    
    let name: String
    let app: Application
    
    func run(context: JobContext) -> EventLoopFuture<Void> {
        context.logger.info("job \(self.name)!")
        _ = app.jobs.queue.dispatch(Email.self, .init(to: "tanner@vapor.codes"))
        return context.eventLoop.makeSucceededFuture(())
    }
}
// 任务
struct Email: Job {
    struct Message: Codable {
        var to: String
    }
    
    func dequeue(_ context: JobContext, _ message: Message) -> EventLoopFuture<Void> {
        context.logger.info("sending email to \(message.to)")
        return context.eventLoop.makeSucceededFuture(())
    }
}
