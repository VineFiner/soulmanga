//
//  boot.swift
//  App
//
//  Created by Finer  Vine on 2020/1/5.
//

import Vapor
import Jobs
// Called before commands run after boot.
public func boot(_ app: Application) throws {
    // jobs
    try JobsCommand(application: app, scheduled: false).startJobs(on: .default)
    // 开启定时任务
    try JobsCommand(application: app, scheduled: true).startScheduledJobs()
    // 自动 migrate
    _ = app.autoMigrate()
}
