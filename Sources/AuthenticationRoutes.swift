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

class GithubAuthentication {
    let id: Int32
    let token: String
    let hashedToken: String
    
    init(id:Int32, token: String, hashedToken: String) {
        self.id = id
        self.token = token
        self.hashedToken = hashedToken
    }
}

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

class GithubAuthenticationRoutes {
    unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
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
