//
//  EmailJob.swift
//  App
//
//  Created by Finer  Vine on 2020/2/12.
//

import Vapor
import Jobs

// 任务
class Email: Job {
    
    let app: Application
    var count: Int = 0
    
    init(app: Application) {
        self.app = app
    }
    
    struct Message: Codable {
        var to: String
    }
    
    func dequeue(_ context: JobContext, _ message: Message) -> EventLoopFuture<Void> {
        context.logger.info("sending email to \(message.to)")
        // 这里进行网络请求
//        todoInfo()
//        fetchInfo()
        createInfo()
        return context.eventLoop.makeSucceededFuture(())
    }
    // MARK: private
    func fetchInfo() {
        let client: Application.Client = app.client
        let httpClient = client.http
        httpClient.get(url: "http://localhost:8080/todos").whenComplete { result in
            switch result {
            case .failure(let error):
            // process error
                print(error)
            case .success(let response):
                if response.status == .ok {
                    // handle response
                    print(response)
                } else {
                    // handle remote error
                    print(response)
                }
            }
        }
        
    }
        
    func todoInfo() {
        struct Hello: Codable {
            let message: String
        }
        let client: Application.Client = app.client
        let url: URI = URI(string: "http://127.0.0.1:8080/greeting2")
        _ = client.get(url).map { (response: ClientResponse) in
            switch response.status {
            case .ok:
                let todo = try? response.content.decode(Hello.self)
                print(todo ?? "")
                break
            default :
                break
            }
        }
    }
    
    func createInfo() {
        let client: Application.Client = app.client
        let httpClient = client.http
        
        guard var request = try? HTTPClient.Request(url: "http://localhost:8080/todos/", method: .POST) else { return }
        request.headers.add(name: "User-Agent", value: "Swift HTTPClient")
        request.headers.add(name: "Content-Type", value: "application/json")
        
        struct Info: Encodable {
            let title: String
        }
        count = count + 1
        let info = Info(title: "\(count)")
        if let infoData = try? JSONEncoder().encode(info) {
            request.body = HTTPClient.Body.data(infoData)
        }
        httpClient.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                // process error
                print(error)
            case .success(let response):
                if response.status == .ok {
                    // handle response
                    print(response)
                } else {
                    // handle remote error
                    print(response)
                }
            }
        }
    }
}
