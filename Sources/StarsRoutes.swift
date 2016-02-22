//
//  StarsRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-22.
//
//

import Foundation

public class StarsRoutes {
    public unowned let client: GithubNetWorkClient
    
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Users that stars a repo belongs to a user.
     
     - parameter repo: repo name
     - parameter name: owner
     - parameter page: when user has a lot of repos, pagination will be applied.
     
     - returns: an RpcRequest, whose response result contains `[GithubUser]`, if pagination is applicable, response result contains `nextpage`.
     */
    public func getStargazersFor(repo repo: String, owner: String, page: String = "1") -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
        precondition((repo.characters.count != 0 && owner.characters.count != 0), "Invalid Input")
        
        let httpResponseHandler:((NSHTTPURLResponse?)->String?)? = { (response: NSHTTPURLResponse?) in
            if let nonNilResponse = response,
                link = (nonNilResponse.allHeaderFields["Link"] as? String),
                sinceRange = link.rangeOfString("page=") {
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
        
        return RpcCustomResponseRequest(client: self.client, host: "api", route: "/repos/\(owner)/\(repo)/stargazers", method: .GET, params: ["page":page], postParams: nil, postData: nil,customResponseHandler:httpResponseHandler, responseSerializer: UserArraySerializer(), errorSerializer: StringSerializer())
    }
}