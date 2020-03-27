import Fluent
import Vapor

struct TodoController {
    /// http://127.0.0.1:8080/todos
    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }

    /// http://127.0.0.1:8080/todos body { "title":"one"}
    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).map { todo }
    }

    /// http://127.0.0.1:8080/todos/update/3 body { "title":"3"}
    func update(req: Request) throws -> EventLoopFuture<Todo> {
        
        struct UpdateTodo: Content {
            var title: String
        }
        let updateTodo = try req.content.decode(UpdateTodo.self)
                
        let searchResult: EventLoopFuture<Todo> = Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        let updateResult = searchResult.flatMap { (todo) -> EventLoopFuture<Todo> in
            todo.title = updateTodo.title
            let newTodo = todo.update(on: req.db).transform(to: todo)
            return newTodo
        }
        
        return updateResult
    }
    
    /// http://127.0.0.1:8080/todos/3
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
