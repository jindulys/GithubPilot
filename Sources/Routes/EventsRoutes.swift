//
//  EventsRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

/// Routes responsible for Events related request.
open class EventsRoutes {
	open unowned let client: GithubNetWorkClient
	
	init(client: GithubNetWorkClient) {
		self.client = client
	}
	
	/**
	Events that a user has received
	
	- parameter name: user
	- parameter page: when user has a lot of repos, pagination will be applied.
	
	- returns: an RpcRequest, whose response result contains `[GithubEvent]`, if pagination is applicable, response result contains `nextpage`.
	*/
	open func getReceivedEventsForUser(_ name: String, page: String = "1") -> RpcCustomResponseRequest<EventArraySerializer, StringSerializer, String> {
		if name.characters.count == 0 {
			print(Constants.ErrorInfo.InvalidInput.rawValue)
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
		
		return RpcCustomResponseRequest(client: self.client,
		                                host: "api",
		                                route: "/users/\(name)/received_events",
																		method: .get,
																		params: ["page":page],
																		postParams: nil,
																		postData: nil,
																		customResponseHandler:httpResponseHandler,
																		responseSerializer: EventArraySerializer(),
																		errorSerializer: StringSerializer())
	}
}
