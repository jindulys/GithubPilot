//
//  EventsRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

public class EventsRoutes {
    public unowned let client: GithubNetWorkClient
    
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Events that a user has received
     
     - parameter name: user
     - parameter page: when user has a lot of repos, pagination will be applied.
     
     - returns: an RpcRequest, whose response result contains `[GithubEvent]`, if pagination is applicable, response result contains `nextpage`.
     */
    public func getReceivedEventsForUser(name: String, page: String = "1") -> RpcCustomResponseRequest<EventArraySerializer, StringSerializer, String> {
        precondition(name.characters.count != 0, "Invalid Input")
        
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
        
        return RpcCustomResponseRequest(client: self.client, host: "api", route: "/users/\(name)/received_events", method: .GET, params: ["page":page], postParams: nil, postData: nil,customResponseHandler:httpResponseHandler, responseSerializer: EventArraySerializer(), errorSerializer: StringSerializer())
    }
}