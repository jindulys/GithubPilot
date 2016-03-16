//
//  UserRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-17.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/// Routes for User related Request.
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
        if since.characters.count == 0 {
            print(Constants.ErrorInfo.InvalidInput.rawValue)
        }
        
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
    
    /**
     Get a user's full information through API url.
     
     - parameter url: user's api url, e.g `https://api.github.com/users/octocat`.
     
     - returns: a DirectAPIRequest, which you could use to get user's info through `response` method.
     */
    public func getAPIUser(url url: String) -> DirectAPIRequest<GithubUserSerializer, StringSerializer> {
        if url.characters.count == 0 {
            print("GithubPilotError Invalid input")
        }
        return DirectAPIRequest(client: self.client, apiURL: url, method: .GET, responseSerializer: GithubUserSerializer(), errorSerializer: StringSerializer())
    }
    
    /**
     Get a list of users' full information
     
     - parameter userAPIURLs:       a list of url contains userAPIURL, which could be used to fetch for the full information
     - parameter complitionHandler: callback when all users get fetched, contains full information of users.
     */
    public func getFullUsers(userAPIURLs: [String], complitionHandler:([GithubUser]?)->Void) {
        let fetchUserGroup = dispatch_group_create()
        var results: [GithubUser] = []
        for url in userAPIURLs {
            if url.characters.count > 0 {
                // Enter group
                dispatch_group_enter(fetchUserGroup)
                getAPIUser(url: url).response({ (result, error) -> Void in
                    if let fetchError = error {
                        print("Meeet an error \(fetchError)")
                        dispatch_group_leave(fetchUserGroup)
                    }
                    
                    if let user = result {
                        results.append(user)
                        dispatch_group_leave(fetchUserGroup)
                    }
                })
            }
        }
        
        dispatch_group_notify(fetchUserGroup, dispatch_get_main_queue()) { () -> Void in
            complitionHandler(results)
        }
    }
}