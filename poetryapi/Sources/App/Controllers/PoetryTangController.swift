//
//  PoetryTangController.swift
//  App
//
//  Created by Finer  Vine on 2019/12/28.
//

import Vapor
import Fluent
import FluentSQLiteDriver

struct PoetryTangController {
    // 加载本地
    func loadLocal(req: Request) throws -> EventLoopFuture<[PoetryTang]> {
        let decodedPoetryTangs = try PoetryTang.loadFromFile()
        let result = decodedPoetryTangs.compactMap { (poetry) -> EventLoopFuture<PoetryTang> in
            let newPoetry = poetry.save(on: req.db).map { poetry }
            return newPoetry
        }
        return req.eventLoop.flatten(result)
    }
    
    // 获取所有
    func getAll(req: Request) throws -> EventLoopFuture<[PoetryTang]> {
        return PoetryTang.query(on: req.db).all()
    }
    // 获取单个
    func getSingle(req: Request) throws -> EventLoopFuture<PoetryTang> {
        guard let poetryID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.notFound, reason: "No poetry matched the provided id")
        }
        print("id:\(poetryID)")
        return PoetryTang.find(poetryID, on: req.db).unwrap(or: Abort(.notFound))
    }
}
