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
     Get a single user.
     
     - parameter username: a Github user's username.
     
     - returns: an RpcRequest, whose response result is `GithubUser`.
     */
    public func getUser(username username: String) -> RpcRequest<GithubUserSerializer, StringSerializer> {
        return RpcRequest(client: self.client, host: "api", route: "/users/\(username)", method: .GET, responseSerializer: GithubUserSerializer(), errorSerializer: StringSerializer())
    }
    
    /**
     Get current authenticated user.
     
     - returns: an RpcRequest, whose response result is `GithubUser`.
     */
    public func getAuthenticatedUser() -> RpcRequest<GithubUserSerializer, StringSerializer> {
        return RpcRequest(client: self.client, host: "api", route: "/user", method: .GET, responseSerializer: GithubUserSerializer(), errorSerializer: StringSerializer())
    }
    
    /**
     Get all Users, this is a pagination request, you could get `since` which represent next page of users' start ID from `.response` complitionHandler's first paramete
     
     - parameter since: The integer ID of the last User that you've seen, you could get this from `.response` complitionHandler's first parameter
     
     - returns: an RpcCustomResponseRequest
     */
    public func getAllUsers(since: String) -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
        let params = ["since": since]
        
        let httpResponseHandler:((NSHTTPURLResponse?)->String?)? = { (response: NSHTTPURLResponse?) in
            if let nonNilResponse = response,
                link = (nonNilResponse.allHeaderFields["Link"] as? String),
                sinceRange = link.rangeOfString("since=") {
                    var retVal = ""
                    var checkIndex = sinceRange.endIndex

                    while checkIndex != link.endIndex {
                        let character = link.characters[checkIndex]
                        let characterInt = character.zeroCharacterBasedunicodeScalarCodePoint()
                        if characterInt>=0 && characterInt<=9 {
                            retVal += String(character)
                        } else {
                            break
                        }
                        checkIndex = checkIndex.successor()
                    }
                    return retVal
            }
            return nil
        }
        
        return RpcCustomResponseRequest(client: self.client, host: "api", route: "/users", method: .GET, params: params, postParams: nil, postData: nil,customResponseHandler:httpResponseHandler, responseSerializer: UserArraySerializer(), errorSerializer: StringSerializer())
    }
}