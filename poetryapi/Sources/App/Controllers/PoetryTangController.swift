//
//  PoetryTangController.swift
//  App
//
//  Created by Finer  Vine on 2019/12/28.
//

import Vapor
import Fluent

struct PoetryTangController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        //    routes.get("api", "loadlocal",use: poetryTang.loadLocal)
        routes.get("api", "poetrytang",use:getAll)
        routes.get("api", "poetrytang", "index", use: index)
        routes.get("api", "poetrytang", ":id", use: getSingle)
        routes.get("api", "poetrytang", "search", use: queryTitle)
    }
    // 加载本地 http://127.0.0.1:8080/api/loadlocal
    /*
    func loadLocal(req: Request) throws -> EventLoopFuture<[PoetryTang]> {
        let decodedPoetryTangs = try PoetryTang.loadFromFile(try Data.fromFile("poet.tang.0.json"))
        let result = decodedPoetryTangs.compactMap { (poetry) -> EventLoopFuture<PoetryTang> in
            let newPoetry = poetry.save(on: req.db).map { poetry }
            return newPoetry
        }.flatten(on: req.eventLoop)
        return result
    }
    */
    // 分页获取 http://127.0.0.1:8080/api/poetrytang/index?page=1&per=10
    func index(req: Request) throws -> EventLoopFuture<Page<PoetryTang>> {
        
        struct PageInfo: Codable {
            var page: Int
            var per: Int
        }
        var pageInfo = try req.query.decode(PageInfo.self)
        print(pageInfo)
        // 这里限定显示30个
        if pageInfo.per > 30 {
            pageInfo.per = 30
        }
        // 这里是分页
        let page: EventLoopFuture<Page<PoetryTang>> = PoetryTang.query(on: req.db)
            /// 这里限定显示
//            .range(..<30)
            /// 这里是分页
            .paginate(PageRequest(page: pageInfo.page, per: pageInfo.per))
//            .paginate(for: req)
            
        return page.map { (page: Page<PoetryTang>) -> Page<PoetryTang> in
                let simple: Page<PoetryTang> = page.map { (tang) -> PoetryTang in
                    if tang.isSimplified == true {
                        return tang
                    }
                    // 转为简体
                    tang.isSimplified = true
                    tang.title = tang.title.simplified
                    tang.author = tang.author.simplified
                    tang.content = tang.content?.simplified
                    _ = tang.update(on: req.db)
                    return tang
                }
                return simple
            }
    }
    // 获取所有 http://127.0.0.1:8080/api/poetrytang
    func getAll(req: Request) throws -> EventLoopFuture<[PoetryTang]> {
        return PoetryTang.query(on: req.db)
            .range(..<100)
            .all()
    }
    
    // 获取单个 http://127.0.0.1:8080/api/poetrytang/30A199AC-E508-46C2-B3ED-ECBCDA4E4D81
    func getSingle(req: Request) throws -> EventLoopFuture<PoetryTang> {
        guard let poetryID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.notFound, reason: "No poetry matched the provided id")
        }
        print("id:\(poetryID)")
        return PoetryTang.find(poetryID, on: req.db).unwrap(or: Abort(.notFound))
    }
    
    // 查询 http://127.0.0.1:8080/api/poetrytang/search?title=将军行
    func queryTitle(req: Request) throws -> EventLoopFuture<[PoetryTang]> {
        guard let poetryTitle = req.query[String.self, at: "title"] else {
            throw Abort(.notFound, reason: "No poetry matched the provided id")
        }
        let traTitle = poetryTitle.traditional
        print("id:\(traTitle)")
        // ~~ 模糊匹配。
//        let result = PoetryTang.query(on: req.db).filter(\.$title ~~ traTitle).all()
        let result = PoetryTang.query(on: req.db)
            .group(.or) { query in
                query.filter(\.$title == poetryTitle)
                    .filter(\.$content == poetryTitle)
                    .filter(\.$title == traTitle)
                    .filter(\.$content == traTitle)
            }
            .all()
        return result
    }
}
