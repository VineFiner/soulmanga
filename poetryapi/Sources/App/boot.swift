//
//  boot.swift
//  App
//
//  Created by vine on 2020/3/26.
//

import Vapor
import Queues
// Called before commands run after boot.
public func boot(_ app: Application) throws {
    // Jobs
    try QueuesCommand(application: app, scheduled: false).startJobs(on: .default)
    // 开启定时任务
    try QueuesCommand(application: app, scheduled: true).startScheduledJobs()
    // 自动 migrate
    _ = app.autoMigrate()
}
