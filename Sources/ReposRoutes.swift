//
//  ReposRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

public class ReposRoutes {
    public unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Get current authenticated user.
     
     - returns: an RpcRequest, whose response result is `GithubUser`.
     */
    public func getAuthenticatedUserRepos() -> RpcRequest<RepoArraySerializer, StringSerializer> {
        return RpcRequest(client: self.client, host: "api", route: "/user/repos", method: .GET, responseSerializer: RepoArraySerializer(), errorSerializer: StringSerializer())
    }
}
