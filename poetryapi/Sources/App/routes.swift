import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.delete("todos", ":todoID", use: todoController.delete)
    
    try app.register(collection: PoetryTangController())
    
    try app.register(collection: BookController())
    
    try app.register(collection: BookSpiderController())
    
    try app.register(collection: GreetingController())
}
