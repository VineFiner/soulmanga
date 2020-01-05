//
//  JobsNormalDriver.swift
//  App
//
//  Created by Finer  Vine on 2020/1/5.
//
import Jobs
import Vapor

struct JobsNormalDriver: JobsDriver {
    func makeQueue(with context: JobContext) -> JobsQueue {
        TestQueue(context: context)
    }
    
    func shutdown() {
        // nothing
    }
}

struct TestQueue: JobsQueue {
    static var queue: [JobIdentifier] = []
    static var jobs: [JobIdentifier: JobData] = [:]
    static var lock: Lock = .init()
    
    let context: JobContext
    
    func get(_ id: JobIdentifier) -> EventLoopFuture<JobData> {
        TestQueue.lock.lock()
        defer { TestQueue.lock.unlock() }
        return self.context.eventLoop.makeSucceededFuture(TestQueue.jobs[id]!)
    }
    
    func set(_ id: JobIdentifier, to data: JobData) -> EventLoopFuture<Void> {
        TestQueue.lock.lock()
        defer { TestQueue.lock.unlock() }
        TestQueue.jobs[id] = data
        return self.context.eventLoop.makeSucceededFuture(())
    }
    
    func clear(_ id: JobIdentifier) -> EventLoopFuture<Void> {
        TestQueue.lock.lock()
        defer { TestQueue.lock.unlock() }
        TestQueue.jobs[id] = nil
        return self.context.eventLoop.makeSucceededFuture(())
    }
    
    func pop() -> EventLoopFuture<JobIdentifier?> {
        TestQueue.lock.lock()
        defer { TestQueue.lock.unlock() }
        return self.context.eventLoop.makeSucceededFuture(TestQueue.queue.popLast())
    }
    
    func push(_ id: JobIdentifier) -> EventLoopFuture<Void> {
        TestQueue.lock.lock()
        defer { TestQueue.lock.unlock() }
        TestQueue.queue.append(id)
        return self.context.eventLoop.makeSucceededFuture(())
    }
}
