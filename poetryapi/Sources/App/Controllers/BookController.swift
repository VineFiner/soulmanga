//
//  BookController.swift
//  App
//
//  Created by Finer  Vine on 2020/2/12.
//

import Vapor
import Fluent

struct BookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("api", "bookinfo", use: fetchBookInfo)
    }
    
    /// 获取书籍信息
    func fetchBookInfo(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let bookID = req.parameters.get("id") ?? "1"
        let bookUrlString = "https://www.52bqg.com/book_\(bookID)/"
        let bookUrl: URI = URI(string: bookUrlString)
        return req.client.get(bookUrl).map { (response: ClientResponse) -> (HTTPStatus) in
            switch response.status {
            case .ok:
                let todo = try? response.content.decode(String.self)
                print(todo ?? "")
                break
            default :
                break
            }
            
            return HTTPStatus.ok
        }
    }
}
