//
//  OAuth.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

public enum GithubAuthResult {
    case Success(String)
    case Error(String)
}

public class GithubAuthManager {
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let oAuthRouter: GithubAuthenticationRoutes
    let oAuthClient: GithubNetWorkClient
    let scope: [String]
    
    var code: String?
    var accessToken: String?
    var oAuthResult: GithubAuthResult?
    
    public static var sharedAuthManager: GithubAuthManager!

    init(clientID: String, clientSecret: String, scope:[String], redirectURI: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.scope = scope
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let manager = Alamofire.Manager(configuration:configuration)
        manager.startRequestsImmediately = false
        self.oAuthClient = GithubNetWorkClient(manager: manager,
                                        baseHosts: [
                                            "login": "https://github.com",
                                            "api": "https://api.github.com"])
        self.oAuthRouter = GithubAuthenticationRoutes(client: self.oAuthClient)
    }
    
    /**
     Authenticate client with Github authrization server. This is the first step of
     Github OAuth procedure.
     */
    public func authenticate() {
        if let accessToken = DefaultStorage.get(key: Constants.AccessToken.GithubAccessTokenStorageKey) as? String {
            self.accessToken = accessToken
            self.oAuthResult = .Success(accessToken)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.GithubAccessTokenRequestSuccess, object: nil)
        } else {
            self.oAuthRouter.requestAuthentication(self.scope, clientID: self.clientID, redirectURI: self.redirectURI)
        }
    }
    
    public func requestAccessToken(url: NSURL) {
        guard let code = url.query?.componentsSeparatedByString("code=").last else { return }
        self.oAuthRouter.requestAccessToken(self.clientID, clientSecret: self.clientSecret, code: code) { (tokenString, requestError) -> Void in
            if let error = requestError {
                self.oAuthResult = .Error(error.description)
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.GithubAccessTokenRequestFailure, object: nil)
                return
            }
            
            if let result = tokenString {
                let components = result.componentsSeparatedByString("&")
                componentLoop: for component in components {
                    let items = component.componentsSeparatedByString("=")
                    var isToken = false
                    itemLoop: for item in items {
                        if isToken {
                            self.accessToken = item
                            self.oAuthResult = .Success(item)
                            // Clear storaged access token
                            DefaultStorage.clear(key: Constants.AccessToken.GithubAccessTokenStorageKey)
                            // Save access token
                            DefaultStorage.save(item,
                                                withKey: Constants.AccessToken.GithubAccessTokenStorageKey)
                            break componentLoop
                        }
                        
                        if item == "access_token" {
                            isToken = true
                        }
                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.GithubAccessTokenRequestSuccess, object: nil)
            }
        }
    }
    
    public func clearStoredAccessToken() {
        DefaultStorage.clear(key: Constants.AccessToken.GithubAccessTokenStorageKey)
    }
}

protocol PersistentStorage {
    typealias valueType
    typealias keyType
    
    static func save(info: valueType, withKey key: keyType) -> Void
    static func get(key key: keyType) -> AnyObject?
    static func clear(key key: keyType) -> Void
}

/// DefaultStorage use NSDefault to save information
class DefaultStorage: PersistentStorage  {
    
    class func save(info: AnyObject, withKey key: String) -> Void {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(info, forKey: key)
    }
    
    class func get(key key: String) -> AnyObject? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let value = defaults.objectForKey(key) {
            return value
        }
        return nil
    }
    
    class func clear(key key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
    }
}

