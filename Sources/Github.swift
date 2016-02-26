//
//  Github.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/// Convenience Class
public class Github {
    /// authorizedClient used for the whole app to interact with Github API.
    public static var authorizedClient: GithubClient?
    /// authenticatedUser is the user who authenticates this client.
    public static var authenticatedUser: GithubUser?
    
    /**
     This method should be called at the very first to setup related Object.
     
     - parameter clientID:     your clientID registered at Github Developer Page.
     - parameter clientSecret: your clientSecret registered at Github Developer Page.
     - parameter scope:        scopes you want your client to have.
     - parameter redirectURI:  unique URL that your client could deal with.
     */
    public static func setupClientID(clientID: String, clientSecret: String, scope:[String], redirectURI: String) {
        precondition(GithubAuthManager.sharedAuthManager == nil, "Only call `Github.setupClientID` once")
        GithubAuthManager.sharedAuthManager = GithubAuthManager(clientID: clientID, clientSecret: clientSecret, scope: scope, redirectURI: redirectURI)
        GithubManager.sharedManager = GithubManager()
    }
    
    /**
     Authenticate this client, should be called after `setupClientID(_, clientSecret:,scope:,redirectURI:)`
     */
    public static func authenticate() {
        precondition(GithubAuthManager.sharedAuthManager != nil, "Call `Github.setupClientID` before this method")
        GithubAuthManager.sharedAuthManager.authenticate()
    }
    
    /**
     Request AccessToken.
     
     - parameter url: url returned by Authentication Server, this usually should be called from `application(_, openURL:,sourceApplication:,annotation)`
     */
    public static func requestAccessToken(url: NSURL) {
        precondition(GithubAuthManager.sharedAuthManager != nil, "Call `Github.setupClientID` before this method")
        GithubAuthManager.sharedAuthManager.requestAccessToken(url)
    }
    
    /**
     Unlink this app.
     */
    public static func unlink() {
        precondition(GithubAuthManager.sharedAuthManager != nil, "Call `Github.setupClientID` before this method")
        if Github.authorizedClient == nil {
            return
        }
        
        GithubAuthManager.sharedAuthManager.clearStoredAccessToken()
        Github.authorizedClient = nil
    }
}

/// Object used for monitor Notification
class GithubManager: NSObject {
    static var sharedManager: GithubManager!
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"receivedGithubAccessToken", name: Constants.NotificationKey.GithubAccessTokenRequestSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedGithubAccessTokenFailure", name: Constants.NotificationKey.GithubAccessTokenRequestFailure, object: nil)
    }
    
    func receivedGithubAccessToken() {
        precondition(GithubAuthManager.sharedAuthManager != nil, "Call `Github.setupClientID` before calling this method")
        precondition(Github.authorizedClient == nil, "Client has already been authorized")
        
        if let accessToken = GithubAuthManager.sharedAuthManager.accessToken {
            Github.authorizedClient = GithubClient(accessToken: accessToken)
            Github.authorizedClient?.users.getAuthenticatedUser().response({ (result, error) -> Void in
                if let user = result {
                    Github.authenticatedUser = user
                }
                // TODO: what if we could not get authenticated user, does this matter a lot?
            })
        }
    }
    
    func receivedGithubAccessTokenFailure() {
        // TODO: save the error to display to the user
        print("Failed to get access token")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}