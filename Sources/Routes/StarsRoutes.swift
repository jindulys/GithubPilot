//
//  StarsRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-22.
//
//

import Foundation

/// Routes for Stars related request.
open class StarsRoutes {
	open unowned let client: GithubNetWorkClient
	// This queue is used for some long time task to stay around, espicially pagination operation.
	let longTimeWaitQueue: DispatchQueue
	
	init(client: GithubNetWorkClient) {
		self.client = client
		self.longTimeWaitQueue = DispatchQueue(label: "com.githubpilot.stargazersRoutes.waitingQueue", attributes: [])
	}
	
	/**
	Users that stars a repo belongs to a user.
	
	- parameter repo: repo name
	- parameter name: owner
	- parameter page: when user has a lot of repos, pagination will be applied.
	
	- returns: an RpcRequest, whose response result contains `[GithubUser]`, if pagination is applicable, response result contains `nextpage`.
	*/
	open func getStargazersFor(repo: String, owner: String, page: String = "1", defaultResponseQueue: DispatchQueue? = nil) -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
		if repo.characters.count == 0 || owner.characters.count == 0 {
			print("Repo name and Owner name must not be empty")
		}
		
		let httpResponseHandler:((HTTPURLResponse?)->String?)? = { (response: HTTPURLResponse?) in
			if let nonNilResponse = response,
				let link = (nonNilResponse.allHeaderFields["Link"] as? String),
				let sinceRange = link.range(of: "page=") {
				var retVal = ""
				var checkIndex = sinceRange.upperBound
				
				while checkIndex != link.endIndex {
					let character = link.characters[checkIndex]
					let characterInt = character.zeroCharacterBasedunicodeScalarCodePoint()
					if characterInt>=0 && characterInt<=9 {
						retVal += String(character)
					} else {
						break
					}
					checkIndex = link.index(after: checkIndex)
				}
				return retVal
			}
			return nil
		}
		
		return RpcCustomResponseRequest(client: self.client, host: "api", route: "/repos/\(owner)/\(repo)/stargazers", method: .get, params: ["page":page], postParams: nil, postData: nil,customResponseHandler:httpResponseHandler, defaultResponseQueue: defaultResponseQueue, responseSerializer: UserArraySerializer(), errorSerializer: StringSerializer())
	}
	
	/**
	Get all the stargazers belong to a owner's repo.
	
	- note: This request is time consuming if this repo is a quite popular one. but it will run on a private serial queue and will not block main queue.
	
	- parameter repo:              repo's name.
	- parameter owner:             owner's name.
	- parameter complitionHandler: callback that call on main thread.
	*/
	fileprivate func getAllStargazersOldFor(repo: String, owner: String, complitionHandler:@escaping ([GithubUser]?, String?)-> Void) {
		self.longTimeWaitQueue.async { () -> Void in
			let privateQueue = DispatchQueue(label: "com.githubpilot.stargazersRoutes.responseQueue", attributes: [])
			var retVal: [GithubUser] = []
			var retError: String?
			let semaphore = DispatchSemaphore(value: 0)
			var recursiveStargazers: (String, String, String, DispatchQueue?) -> Void = {_, _, _, _ in }
			recursiveStargazers = {
				repo, owner, page, queue in
				self.getStargazersFor(repo: repo, owner: owner, page: page, defaultResponseQueue: queue).response {
					(nextPage, result, error) -> Void in
					if let error = error {
						retError = error.description
						semaphore.signal()
					}
					
					if let users = result {
						retVal.append(contentsOf: users)
					}
					
					if let vpage = nextPage {
						if vpage == "1" {
							semaphore.signal()
						} else {
							recursiveStargazers(repo, owner, vpage, queue)
						}
					}
				}
			}
			
			recursiveStargazers(repo, owner, "1", privateQueue)
			let timeoutTime = DispatchTime.now() + Double(Int64(100 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
			if semaphore.wait(timeout: timeoutTime) == .timedOut {
				retError = Constants.ErrorInfo.RequestOverTime.rawValue
			}
			DispatchQueue.main.async(execute: { () -> Void in
				complitionHandler(retVal, retError)
			})
		}
	}
	
	/**
	Get all the stargazers belong to a owner's repo.
	
	- note: This request is time consuming if this repo is a quite popular one. but it will run on a private serial queue and will not block main queue.
	
	- parameter repo:              repo's name.
	- parameter owner:             owner's name.
	- parameter complitionHandler: callback that call on main thread.
	*/
	open func getAllStargazersFor(repo: String, owner: String, complitionHandler:@escaping ([GithubUser]?, String?)-> Void) {
		var recursiveStargazers: (String, String, String) -> Void = {_, _, _ in }
		var retVal: [GithubUser] = []
		recursiveStargazers = {
			repo, owner, page in
			self.getStargazersFor(repo: repo, owner: owner, page: page).response {
				(nextPage, result, error) -> Void in
				guard let users = result, let vpage = nextPage else {
					complitionHandler(nil, error?.description ?? "Error,Could not finish this request")
					return
				}
				
				retVal.append(contentsOf: users)
				if vpage == "1" {
					complitionHandler(retVal, nil)
				} else {
					recursiveStargazers(repo, owner, vpage)
				}
			}
		}
		
		recursiveStargazers(repo, owner, "1")
	}
}
