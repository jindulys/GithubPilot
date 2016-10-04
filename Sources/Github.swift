//
//  Github.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/// Convenience Class
open class Github {
	/// authorizedClient used for the whole app to interact with Github API.
	open static var authorizedClient: GithubClient?
	/// authenticatedUser is the user who authenticates this client.
	open static var authenticatedUser: GithubUser?
	
	/**
	This method should be called at the very first to setup related Object.
	
	- parameter clientID:     your clientID registered at Github Developer Page.
	- parameter clientSecret: your clientSecret registered at Github Developer Page.
	- parameter scope:        scopes you want your client to have.
	- parameter redirectURI:  unique URL that your client could deal with.
	*/
	open static func setupClientID(_ clientID: String, clientSecret: String, scope:[String], redirectURI: String) {
		if GithubAuthManager.sharedAuthManager != nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Only call `Github.setupClientID` once")
		}
		GithubAuthManager.sharedAuthManager = GithubAuthManager(clientID: clientID, clientSecret: clientSecret, scope: scope, redirectURI: redirectURI)
		
		// Call `sharedManager` once, to create this singleton.
		_ = GithubManager.sharedManager
	}
	
	/**
	Authenticate this client, should be called after `setupClientID(_, clientSecret:,scope:,redirectURI:)`
	*/
	open static func authenticate() {
		if GithubAuthManager.sharedAuthManager == nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Call `Github.setupClientID` before this method")
		}
		GithubAuthManager.sharedAuthManager.authenticate()
	}
	
	/**
	Request AccessToken.
	
	- parameter url: url returned by Authentication Server, this usually should be called from `application(_, openURL:,sourceApplication:,annotation)`
	*/
	open static func requestAccessToken(_ url: URL) {
		if GithubAuthManager.sharedAuthManager == nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Call `Github.setupClientID` before this method")
		}
		
		GithubAuthManager.sharedAuthManager.requestAccessToken(url)
	}
	
	/**
	Unlink this app.
	*/
	open static func unlink() {
		if GithubAuthManager.sharedAuthManager == nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Call `Github.setupClientID` before this method")
		}
		
		if Github.authorizedClient == nil {
			return
		}
		
		GithubAuthManager.sharedAuthManager.clearStoredAccessToken()
		Github.authorizedClient = nil
	}
}

/// Object used for monitor Notification
class GithubManager: NSObject {
	static let sharedManager = GithubManager()
	
	fileprivate override init() {
		super.init()
		NotificationCenter.default.addObserver(self, selector:#selector(GithubManager.receivedGithubAccessToken), name: NSNotification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestSuccess), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GithubManager.receivedGithubAccessTokenFailure), name: NSNotification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestFailure), object: nil)
	}
	
	/**
	Get called when get AccessToken.
	*/
	func receivedGithubAccessToken() {
		if GithubAuthManager.sharedAuthManager == nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Call `Github.setupClientID` before this method")
		}
		
		if Github.authorizedClient != nil {
			print(Constants.ErrorInfo.InvalidOperation.rawValue + "Client has already been authorized")
		}
		
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
	
	/**
	Getting AccessToken Failed.
	*/
	func receivedGithubAccessTokenFailure() {
		// TODO: save the error to display to the user
		print("Failed to get access token")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
