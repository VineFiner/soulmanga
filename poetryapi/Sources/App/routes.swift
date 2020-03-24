import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }
    
    struct Hello: Content {
        static let defaultContentType: HTTPMediaType = .urlEncodedForm
        let message = "Hello!"
    }
    app.get("greeting") { req in
        return Hello()
    }
    app.get("greeting2") { req -> Response in
        let res = Response()
        try res.content.encode(Hello(), as: .json)
        return res // {"message":"Hello!"}
    }
    app.get("greeting3") { req -> Response in
        let res = Response()
        res.headers.contentType = .plainText
        res.body = .init(string: "can return image")
        return res // {"message":"Hello!"}
    }
    /*
    app.get("loadlocal") { req -> EventLoopFuture<HTTPStatus> in
        let files = Data.fetchAllFiles()
        var decodedPoetryTangs: [PoetryTang] = []
        for fileURL in files {
            let data = try Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe)
            decodedPoetryTangs.append(contentsOf: try PoetryTang.loadFromFile(data))
        }
        let result = decodedPoetryTangs.compactMap { (poetry) -> EventLoopFuture<PoetryTang> in
            let newPoetry = poetry.save(on: req.db).map { poetry }
            return newPoetry
        }.flatten(on: req.eventLoop)
        return result.map { _ in .ok }
    }
    */
    
    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", "update", ":todoID", use: todoController.update)
    app.post("todos", use: todoController.create)
    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
    
    try app.register(collection: PoetryTangController())
    
    try app.register(collection: BookController())
    
    try app.register(collection: BookSpiderController())
}
