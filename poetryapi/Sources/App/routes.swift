import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
    
    let poetryTang = PoetryTangController()
    app.get("api", "loadlocal",use: poetryTang.loadLocal)
    app.get("api", "poetrytang",use: poetryTang.getAll)
    app.get("api", "poetrytang", ":id", use: poetryTang.getSingle)
}
