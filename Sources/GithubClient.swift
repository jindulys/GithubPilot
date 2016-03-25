//
//  GithubClient.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

/// Class used for all kinds of request, it manages all the routes.
public class GithubClient: GithubNetWorkClient {
    let accessToken: String
    
    public var users: UsersRoutes!
    public var repos: ReposRoutes!
    public var events: EventsRoutes!
    public var stars: StarsRoutes!
    public var searchRepo: GithubSearchRepoRoutes!
    
    /**
     Add additionalHeaders if you want.
     
     - parameter needoauth: need add accessToken to header.
     
     - returns: modified header.
     */
    public override func additionalHeaders(needoauth: Bool) -> [String : String] {
        var headers: [String: String] = [:]
        if needoauth {
            headers["Authorization"] = "token \(accessToken)"
        }
        return headers
    }
    
    /**
     Convenience Initializer
     
     - parameter accessToken: take an access token to initialize
     
     - returns: a client that takes charge of all kinds of API Request.
     */
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
        self.stars = StarsRoutes(client: self)
        self.searchRepo = GithubSearchRepoRoutes(client: self)
    }
}