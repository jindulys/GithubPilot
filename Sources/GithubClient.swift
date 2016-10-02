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
open class GithubClient: GithubNetWorkClient {
    let accessToken: String
    
    open var users: UsersRoutes!
    open var repos: ReposRoutes!
    open var events: EventsRoutes!
    open var stars: StarsRoutes!
    open var searchRepo: GithubSearchRepoRoutes!
    
    /**
     Add additionalHeaders if you want.
     
     - parameter needoauth: need add accessToken to header.
     
     - returns: modified header.
     */
    open override func additionalHeaders(_ needoauth: Bool) -> [String : String] {
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
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(configuration: configuration)
        manager.startRequestsImmediately = false
        self.init(accessToken: accessToken,
                      manager: manager,
                    baseHosts: ["api": "https://api.github.com"])
    }
    
    init(accessToken: String, manager: Alamofire.SessionManager, baseHosts: [String: String]) {
        self.accessToken = accessToken
        super.init(manager: manager, baseHosts: baseHosts)
        self.users = UsersRoutes(client: self)
        self.repos = ReposRoutes(client: self)
        self.events = EventsRoutes(client: self)
        self.stars = StarsRoutes(client: self)
        self.searchRepo = GithubSearchRepoRoutes(client: self)
    }
}
