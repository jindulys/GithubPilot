//
//  GithubClient.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

public class GithubClient: GithubNetWorkClient {
    let accessToken: String
    
    public var users: UsersRoutes!
    public var repos: ReposRoutes!
    public var events: EventsRoutes!
    
    public override func additionalHeaders(needoauth: Bool) -> [String : String] {
        var headers: [String: String] = [:]
        if needoauth {
            headers["Authorization"] = "token \(accessToken)"
        }
        return headers
    }
    
    public convenience init(accessToken: String) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let manager = Alamofire.Manager(configuration:configuration)
        manager.startRequestsImmediately = false
        self.init(accessToken: accessToken,
                      manager: manager,
                    baseHosts: ["api": "https://api.github.com"])
    }
    
    init(accessToken: String, manager: Alamofire.Manager, baseHosts: [String: String]) {
        self.accessToken = accessToken
        super.init(manager: manager, baseHosts: baseHosts)
        self.users = UsersRoutes(client: self)
        self.repos = ReposRoutes(client: self)
        self.events = EventsRoutes(client: self)
    }
}