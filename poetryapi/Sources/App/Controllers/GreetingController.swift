//
//  GreetingController.swift
//  App
//
//  Created by vine on 2020/3/26.
//

import Fluent
import Vapor

struct GreetingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        struct Hello: Content {
            static let defaultContentType: HTTPMediaType = .urlEncodedForm
            let message = "Hello!"
        }
        routes.get("greeting") { req in
            return Hello()
        }
        routes.get("greeting2") { req -> Response in
            let res = Response()
            try res.content.encode(Hello(), as: .json)
            return res // {"message":"Hello!"}
        }
        routes.get("greeting3") { req -> Response in
            let res = Response()
            res.headers.contentType = .plainText
            res.body = .init(string: "can return image")
            return res // {"message":"Hello!"}
        }
        /*
        routes.get("loadlocal") { req -> EventLoopFuture<HTTPStatus> in
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
    }
    
}
