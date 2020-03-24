//
//  BookSpiderController.swift
//  App
//
//  Created by Finer  Vine on 2020/3/24.
//

import SwiftSoup
import Vapor
import Fluent

struct BookSpiderController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api", "craw")
        api.get("bookInfo", use: crawCreateBookInfo)
    }
    
    /// 创建书籍 http://127.0.0.1:8080/api/craw/bookInfo
    func crawCreateBookInfo(req: Request) throws ->  EventLoopFuture<BookInfoContext> {
        let bookID: Int = 1
        let bookUrlString = "https://www.52bqg.com/book_\(bookID)/"
        let bookUrl: URI = URI(string: bookUrlString)
        
        let info = req.client.get(bookUrl) { req in
            // 添加请求头
        }
        .flatMapThrowing { res -> BookInfoContext in
            // 解码内容
//            let info = try res.content.decode(Todo.self)
//            return info
            let resultData = res.body.flatMap { (buffer) -> Data? in
                return buffer.getData(at: 0, length: buffer.readableBytes)
            }
            let html = try self.paraphraseBookInfo(resultData: resultData, bookUrlString: bookUrlString)
            return try BookSpiderController.paserBookInfo(pageUrl: bookUrlString, htmlContent: html)
        }
        .map { json -> BookInfoContext in
            // Handle the json response.
            print(json)
            return json
        }
        return info
    }
}

extension BookSpiderController {
    func paraphraseBookInfo(resultData: Data?, bookUrlString: String) throws -> String {
        let gbk = String.Encoding(rawValue: 2147485234)
        guard let info = resultData, let infoStr = String(data: info, encoding: gbk) else {
            throw Abort(.internalServerError, reason: "解码失败")
        }
        return infoStr
    }
}

extension BookSpiderController {
    
    struct BookInfoContext: Content {
        
        var bookName: String
        var chapters: [ChapterUrlContext]
        
        struct ChapterUrlContext: Content {
            var isDownload: Bool = false
            let title: String
            let linkUrl: String
        }
    }
    
    /// 书籍解析
    static func paserBookInfo(pageUrl: String, htmlContent: String) throws -> BookInfoContext {
        
        var bookName: String = ""
        
        guard let document = try? SwiftSoup.parse(htmlContent) else {
            throw Abort(.internalServerError, reason: "解码失败")
        }
        guard let box_con = try? document.select("div[class='box_con']") else {
            throw Abort(.internalServerError, reason: "解码失败")
        }
        if let info = try? box_con.select("div[id='info']") {
            if let h1 = try? info.select("h1").text() {
                bookName = h1
            }
        }
        
        guard let lists = try? box_con.select("div[id='list']").select("a") else {
            throw Abort(.internalServerError, reason: "解码失败")
        }
        
        var chapters: [BookInfoContext.ChapterUrlContext] = []
        for link in lists {
            if let linkHref = try? link.attr("href"), let linkText = try? link.text(){
                chapters.append(.init(title: linkText, linkUrl: "\(pageUrl)\(linkHref)"))
            }
        }
        let newBookInfo = BookInfoContext(bookName: bookName, chapters: chapters)
        return newBookInfo
    }
}
