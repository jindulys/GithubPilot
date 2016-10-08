//
//  UserRoutes.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-17.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/// Routes for User related Request.
open class UsersRoutes {
	open unowned let client: GithubNetWorkClient
	init(client: GithubNetWorkClient) {
		self.client = client
	}
	
	/**
	Get a single user.
	
	- parameter username: a Github user's username.
	
	- returns: an RpcRequest, whose response result is `GithubUser`.
	*/
	open func getUser(username: String) -> RpcRequest<GithubUserSerializer, StringSerializer> {
		return RpcRequest(client: self.client,
		                  host: "api",
		                  route: "/users/\(username)",
											method: .get,
											responseSerializer: GithubUserSerializer(),
											errorSerializer: StringSerializer())
	}
	
	/**
	Get followers for user.
	
	- parameter user: a Github user's username.
	
	- parameter page: a specific page to query.
	
	- returns: an RpcRequest, where contains an array of followers.
	*/
	open func getFollowersFor(user: String, page: String = "1") -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
		return RpcCustomResponseRequest(client: self.client,
		                                host: "api",
		                                route: "/users/\(user)/followers",
																		method: .get,
																		params: ["page" : page],
																		postParams: nil,
																		postData: nil,
																		customResponseHandler: GPHttpResponseHandler.PageHandler,
																		responseSerializer: UserArraySerializer(),
																		errorSerializer: StringSerializer())
		
	}
	
	/**
	Get following for user.
	
	- parameter user: a Github user's username.
	
	- parameter page: a specific page to query.
	
	- returns: an RpcRequest, where contains an array of followers.
	*/
	open func getFollowingFor(user: String, page: String = "1") -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
		return RpcCustomResponseRequest(client: self.client,
		                                host: "api",
		                                route: "/users/\(user)/following",
																		method: .get,
																		params: ["page" : page],
																		postParams: nil,
																		postData: nil,
																		customResponseHandler: GPHttpResponseHandler.PageHandler,
																		responseSerializer: UserArraySerializer(),
																		errorSerializer: StringSerializer())
	}
	
	/**
	Get current authenticated user.
	
	- returns: an RpcRequest, whose response result is `GithubUser`.
	*/
	open func getAuthenticatedUser() -> RpcRequest<GithubUserSerializer, StringSerializer> {
		return RpcRequest(client: self.client,
		                  host: "api",
		                  route: "/user",
		                  method: .get,
		                  responseSerializer: GithubUserSerializer(),
		                  errorSerializer: StringSerializer())
	}
	
	/**
	Get all Users, this is a pagination request, you could get `since` which represent next page of users' start ID from `.response` complitionHandler's first paramete
	
	- parameter since: The integer ID of the last User that you've seen, you could get this from `.response` complitionHandler's first parameter
	
	- returns: an RpcCustomResponseRequest
	*/
	open func getAllUsers(_ since: String) -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
		if since.characters.count == 0 {
			print(Constants.ErrorInfo.InvalidInput.rawValue)
		}
		let params = ["since": since]
		return RpcCustomResponseRequest(client: self.client,
		                                host: "api",
		                                route: "/users",
		                                method: .get,
		                                params: params,
		                                postParams: nil,
		                                postData: nil,
		                                customResponseHandler: GPHttpResponseHandler.SinceHandler,
		                                responseSerializer: UserArraySerializer(),
		                                errorSerializer: StringSerializer())
	}
	
	/**
	Get a user's full information through API url.
	
	- parameter url: user's api url, e.g `https://api.github.com/users/octocat`.
	
	- returns: a DirectAPIRequest, which you could use to get user's info through `response` method.
	*/
	open func getAPIUser(url: String) -> DirectAPIRequest<GithubUserSerializer, StringSerializer> {
		if url.characters.count == 0 {
			print("GithubPilotError Invalid input")
		}
		return DirectAPIRequest(client: self.client,
		                        apiURL: url,
		                        method: .get,
		                        responseSerializer: GithubUserSerializer(),
		                        errorSerializer: StringSerializer())
	}
	
	/**
	Get a list of users' full information
	
	- parameter userAPIURLs:       a list of url contains userAPIURL, which could be used to fetch for the full information
	- parameter complitionHandler: callback when all users get fetched, contains full information of users.
	*/
	open func getFullUsers(_ userAPIURLs: [String], complitionHandler:@escaping ([GithubUser]?)->Void) {
		let fetchUserGroup = DispatchGroup()
		var results: [GithubUser] = []
		for url in userAPIURLs {
			if url.characters.count > 0 {
				// Enter group
				fetchUserGroup.enter()
				getAPIUser(url: url).response({ (result, error) -> Void in
					if let fetchError = error {
						print("Meeet an error \(fetchError)")
						fetchUserGroup.leave()
					}
					
					if let user = result {
						results.append(user)
						fetchUserGroup.leave()
					}
				})
			}
		}
		
		fetchUserGroup.notify(queue: DispatchQueue.main) { () -> Void in
			complitionHandler(results)
		}
	}
}
