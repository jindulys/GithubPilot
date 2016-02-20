//
//  UserRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-17.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

public class UsersRoutes {
    public unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Get a single user
     
     - parameter username: a Github user's username.
     
     - returns: an RpcRequest, you should use this request's `response` method to get the result.
     */
    public func getUser(username username: String) -> RpcRequest<GithubUserSerializer, StringSerializer> {
        return RpcRequest(client: self.client, host: "api", route: "/users/\(username)", method: .GET, responseSerializer: GithubUserSerializer(), errorSerializer: StringSerializer())
    }
}