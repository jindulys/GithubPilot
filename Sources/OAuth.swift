//
//  OAuth.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

/**
GithubAuthResult Enum

- Success: Success
- Error:   Error
*/
public enum GithubAuthResult {
	case success(String)
	case error(String)
}

/// GithubAuthManager
open class GithubAuthManager {
	let clientID: String
	let clientSecret: String
	let redirectURI: String
	let oAuthRouter: GithubAuthenticationRoutes
	let oAuthClient: GithubNetWorkClient
	let scope: [String]
	
	var code: String?
	var accessToken: String?
	var oAuthResult: GithubAuthResult?
	
	open static var sharedAuthManager: GithubAuthManager!
	
	init(clientID: String, clientSecret: String, scope:[String], redirectURI: String) {
		self.clientID = clientID
		self.clientSecret = clientSecret
		self.redirectURI = redirectURI
		self.scope = scope
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
		let manager = Alamofire.SessionManager(configuration:configuration)
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
	open func authenticate() {
		if let accessToken = DefaultStorage.get(key: Constants.AccessToken.GithubAccessTokenStorageKey) as? String {
			self.accessToken = accessToken
			self.oAuthResult = .success(accessToken)
			NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestSuccess), object: nil)
		} else {
			self.oAuthRouter.requestAuthentication(self.scope, clientID: self.clientID, redirectURI: self.redirectURI)
		}
	}
	
	/**
	Request AccessToken
	
	- parameter url: url with `code` value, got from Authentication Step.
	*/
	open func requestAccessToken(_ url: URL) {
		guard let code = url.query?.components(separatedBy: "code=").last else { return }
		self.oAuthRouter.requestAccessToken(self.clientID, clientSecret: self.clientSecret, code: code) { (tokenString, requestError) -> Void in
			if let error = requestError {
				self.oAuthResult = .error(error.description)
				NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestFailure), object: nil)
				return
			}
			if let result = tokenString {
				let components = result.components(separatedBy: "&")
				componentLoop: for component in components {
					let items = component.components(separatedBy: "=")
					var isToken = false
					itemLoop: for item in items {
						if isToken {
							self.accessToken = item
							self.oAuthResult = .success(item)
							// Clear storaged access token
							DefaultStorage.clear(key: Constants.AccessToken.GithubAccessTokenStorageKey)
							// Save access token
							DefaultStorage.save(item as AnyObject,
							                    withKey: Constants.AccessToken.GithubAccessTokenStorageKey)
							break componentLoop
						}
						
						if item == "access_token" {
							isToken = true
						}
					}
				}
				NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestSuccess), object: nil)
			}
		}
	}
	
	/**
	Clear AccessToken.
	*/
	open func clearStoredAccessToken() {
		DefaultStorage.clear(key: Constants.AccessToken.GithubAccessTokenStorageKey)
	}
}


/**
*  Protocol for PersistentStorage
*/
protocol PersistentStorage {
	associatedtype valueType
	associatedtype keyType
	
	static func save(_ info: valueType, withKey key: keyType) -> Void
	static func get(key: keyType) -> AnyObject?
	static func clear(key: keyType) -> Void
}

/// DefaultStorage use NSDefault to save information
class DefaultStorage: PersistentStorage  {
	/**
	Save info with key to UserDefaults
	
	- parameter info: info to be saved.
	- parameter key:  key.
	*/
	class func save(_ info: AnyObject, withKey key: String) -> Void {
		let defaults = UserDefaults.standard
		defaults.set(info, forKey: key)
	}
	
	/**
	Get info for a key from UserDefaults
	
	- parameter key: key
	
	- returns: related value or nil.
	*/
	class func get(key: String) -> AnyObject? {
		let defaults = UserDefaults.standard
		if let value = defaults.object(forKey: key) {
			return value as AnyObject?
		}
		return nil
	}
	
	/**
	Remove one key from UserDefaults
	
	- parameter key: key to be cleaned.
	*/
	class func clear(key: String) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: key)
	}
}

