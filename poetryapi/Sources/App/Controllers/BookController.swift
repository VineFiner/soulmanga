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
        let api = routes.grouped("api", "book")
        /// 创建书籍
        api.post("createBookInfo", use: createBookInfo)
        /// 获取书籍
        api.get("bookInfos", use: getBookInfo)
        /// 创建章节
        api.post("createChapter", use: createBookChapter)
        /// 获取书籍章节
        api.get("bookAndChapters", use: getBookInfoAndChapters)
    }
    /// 创建书籍 http://127.0.0.1:8080/api/book/createBookInfo
    /*
     {
         "bookName": "Novel"
     }
     */
    func createBookInfo(req: Request) throws -> EventLoopFuture<BookInfo> {
        let bookInfo = try req.content.decode(BookInfo.self)
        return bookInfo.create(on: req.db).map { bookInfo }
    }
    /// 获取书籍  http://127.0.0.1:8080/api/book/bookInfos
    func getBookInfo(req: Request) throws -> EventLoopFuture<[BookInfo]> {
        return BookInfo.query(on: req.db).all()
    }
    /// 创建章节 http://127.0.0.1:8080/api/book/createChapter
    /*
     {
         "title": "标题",
         "link_url": "链接url",
         "content": "内容",
         "bookInfo": {
             "id": 1
         }
     }
     */
    func createBookChapter(req: Request) throws -> EventLoopFuture<BookChapter> {
        let chapter = try req.content.decode(BookChapter.self)
        return chapter.create(on: req.db)
            .map { chapter }
    }
    /// 返回所有书籍 http://127.0.0.1:8080/api/book/bookAndChapters
    func getBookInfoAndChapters(req: Request) throws -> EventLoopFuture<[BookInfo]> {
        return BookInfo.query(on: req.db).with(\.$chapters).all()
    }
    
}
