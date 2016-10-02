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
struct GithubAuthentication {
    let id: Int32
    let token: String
    let hashedToken: String
}

/// Serializer used for Authentication
class GithubAuthenticationSerializer: JSONSerializer {
    init() { }
    
    func serialize(_ value: GithubAuthentication) -> JSON {
        var retVal:[String: JSON] = [:]
        retVal["id"] = Serialization._Int32Serializer.serialize(value.id)
        retVal["token"] = Serialization._StringSerializer.serialize(value.token)
        retVal["hashed_token"] = Serialization._StringSerializer.serialize(value.hashedToken)
        return .dictionary(retVal)
    }
    
    func deserialize(_ json: JSON) -> GithubAuthentication {
        switch json {
            case .dictionary(let dict):
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .null)
                let token = Serialization._StringSerializer.deserialize(dict["token"] ?? .null)
                let hashedToken = Serialization._StringSerializer.deserialize(dict["hashed_token"] ?? .null)
                return GithubAuthentication(id: id, token: token, hashedToken: hashedToken)
            default:
                fatalError("Wrong Type")
        }
    }
}

enum AuthorizationError: CustomStringConvertible {
    case invalidParameter
    case httpError(String)
    case unknownResponse(String)
    
    var description: String {
        switch self {
            case .invalidParameter:
                return "Invalid Parameter please check your parameter format"
            case .httpError(let error):
                return "HTTP Error :\(error)"
            case .unknownResponse(let error):
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
    func requestAuthentication(_ scopes:[String], clientID: String, redirectURI: String) {
        guard let login = self.client.baseHosts["login"] else { return }
        let path = "/login/oauth/authorize"
        // TODO: optimize params generate process, use a cooler way.
        let urlString = "\(login)\(path)?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scopes.joined(separator: ","))"
        if let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
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
    func requestAccessToken(_ clientID: String, clientSecret: String, code: String, complitionHandler: @escaping (String?, AuthorizationError?)->Void) {
        let url = "\(self.client.baseHosts["login"]!)/login/oauth/access_token"
        let accessTokenRequest = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code)"
        guard let postData = accessTokenRequest.data(using: String.Encoding.ascii, allowLossyConversion: true) else {
            return complitionHandler(nil,.invalidParameter)
        }
    
        Alamofire.request(url, method: .post,
                          parameters: ["":""],
                          encoding: DataPostEncoding(data: postData),
                          headers: nil).response { response in
            let d = response.data!
            if let error = response.error, let response = response.response {
                complitionHandler(nil, .httpError("Request Error, code: \(response.statusCode) description:\(error.localizedDescription)"))
            } else {
                if let tokenResponse = NSString(data:d, encoding: String.Encoding.ascii.rawValue) as? String {
                    complitionHandler(tokenResponse, nil)
                } else {
                    complitionHandler(nil,.unknownResponse("could not decode response data"))
                }
            }
        }
        
    }
}
