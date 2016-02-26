//
//  AuthenticationRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-18.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

/// A Simple Class Represent one Authentication Information
class GithubAuthentication {
    let id: Int32
    let token: String
    let hashedToken: String
    
    /**
     Designated Initializer
     
     - parameter id:          id
     - parameter token:       token, this is what we usually want to use.
     - parameter hashedToken: hashedtoken
     
     - returns: an initialized instance
     */
    init(id:Int32, token: String, hashedToken: String) {
        self.id = id
        self.token = token
        self.hashedToken = hashedToken
    }
}

/// Serializer used for Authentication
class GithubAuthenticationSerializer: JSONSerializer {
    init() { }
    
    func serialize(value: GithubAuthentication) -> JSON {
        var retVal:[String: JSON] = [:]
        retVal["id"] = Serialization._Int32Serializer.serialize(value.id)
        retVal["token"] = Serialization._StringSerializer.serialize(value.token)
        retVal["hashed_token"] = Serialization._StringSerializer.serialize(value.hashedToken)
        return .Dictionary(retVal)
    }
    
    func deserialize(json: JSON) -> GithubAuthentication {
        switch json {
            case .Dictionary(let dict):
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .Null)
                let token = Serialization._StringSerializer.deserialize(dict["token"] ?? .Null)
                let hashedToken = Serialization._StringSerializer.deserialize(dict["hashed_token"] ?? .Null)
                return GithubAuthentication(id: id, token: token, hashedToken: hashedToken)
            default:
                fatalError("Wrong Type")
        }
    }
}

enum AuthorizationError: CustomStringConvertible {
    case InvalidParameter
    case HTTPError(String)
    case UnknownResponse(String)
    
    var description: String {
        switch self {
            case .InvalidParameter:
                return "Invalid Parameter please check your parameter format"
            case .HTTPError(let error):
                return "HTTP Error :\(error)"
            case .UnknownResponse(let error):
                return "Unknown response :\(error)"
        }
    }
}

/// Router used for Authentication purpose.

/// This Router is different from other router since the response for this one is not a JSON Format, although we could change this behavior by set HTTP Header fields.
class GithubAuthenticationRoutes {
    unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Request Authentication
     
     - parameter scopes:      scopes used by your client app
     - parameter clientID:    clientID
     - parameter redirectURI: redirectURI should be a unique scheme that your application could deal with.
     */
    func requestAuthentication(scopes:[String], clientID: String, redirectURI: String) {
        guard let login = self.client.baseHosts["login"] else { return }
        let path = "/login/oauth/authorize"
        // TODO: optimize params generate process, use a cooler way.
        let urlString = "\(login)\(path)?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scopes.joinWithSeparator(","))"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            fatalError("Client should have login URL")
        }
    }
    
    // TODO: deal with error, might be create error ENUM for authentication
    /**
    Request to access Token
    
    - parameter clientID:          ClientID, required
    - parameter clientSecret:      ClientSecret, required
    - parameter code:              the code you get from authentication
    - parameter complitionHandler: complitionHandler will return a string contains access_token, or an Error 
    */
    func requestAccessToken(clientID: String, clientSecret: String, code: String, complitionHandler: (String?, AuthorizationError?)->Void) {
        let url = "\(self.client.baseHosts["login"]!)/login/oauth/access_token"
        let accessTokenRequest = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code)"
        guard let postData = accessTokenRequest.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true) else {
            return complitionHandler(nil,.InvalidParameter)
        }
    
        Alamofire.request(.POST, url, parameters: ["":""], encoding:  ParameterEncoding.Custom({ (convertible, _) -> (NSMutableURLRequest, NSError?) in
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            let length = postData.length
            mutableRequest.setValue("\(length)", forHTTPHeaderField: "Content-Length")
            mutableRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            mutableRequest.HTTPBody = postData
            return (mutableRequest, nil)
        }), headers: nil).response { (request, response, data, error) -> Void in
            let d = data!
            if error != nil {
                complitionHandler(nil, .HTTPError("Request Error, code: \(response?.statusCode) description:\(error?.localizedDescription)"))
            } else {
                if let tokenResponse = NSString(data:d, encoding: NSASCIIStringEncoding) as? String {
                    complitionHandler(tokenResponse, nil)
                } else {
                    complitionHandler(nil,.UnknownResponse("could not decode response data"))
                }
            }
        }
        
    }
}
