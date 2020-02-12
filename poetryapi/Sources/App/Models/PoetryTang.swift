//
//  PoetryTang.swift
//  App
//
//  Created by Finer  Vine on 2019/12/28.
//
import Fluent
import Vapor

final class PoetryTang: Model, Content {
    static let schema: String = "poetrytang"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "author")
    var author: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String?
    
    @Field(key: "is_simpled")
    var isSimplified: Bool?
    
    init() { }
    
    init(id: UUID? = nil, author: String, title: String, content: String) {
        self.id = id
        self.author = author
        self.title = title
        self.content = content
    }
}
extension PoetryTang: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("poetrytang")
            .field("id", .uuid, .identifier(auto: false))
            .field("author", .string, .required)
            .field("title", .string, .required)
            .field("content", .string)
            .field("is_simpled", .bool)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("poetrytang").delete()
    }
}

extension PoetryTang {
    static func loadFromFile(_ poetryTangData: Data) throws -> [PoetryTang] {
        let decoder = JSONDecoder()
        let decodedPoetryTangs = try decoder.decode([PoetryTangDecoderObject].self,from: poetryTangData)
        return decodedPoetryTangs.map { PoetryTang(from: $0)}
    }
    private convenience init(from service: PoetryTangDecoderObject) {
        self.init(id: service.id, author: service.author, title: service.title, content: service.paragraphs.joined(separator: "\n"))
    }
    private struct PoetryTangDecoderObject: Decodable {
        let id: UUID
        let title: String
        let author: String
        let paragraphs: [String]
    }
}
