//
//  SearchRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-03-23.
//
//

import Foundation
import Alamofire


/**
Enumeration for Github Search Query Parameters
*/
public enum GitHubSearchCondition: String {
	// Comm Search Condition
	case Within = "in"
	case Size = "size"
	case Fork = "fork"
	case User = "user"
	case Repo = "repo"
	case Language = "language"
	
	// Sepecific for Search Repo
	case Forks = "forks"
	case Created = "created"
	case Pushed = "pushed"
	case Stars = "stars"
	
	// Sepecific for Search Code
	case Extension = "extension"
	case FileName = "filename"
	case Path = "path"
	
	// Sepecific for Search Users
	case `Type` = "type"
	case Repos = "repos"
	case Location = "location"
	case Followers = "followers"
}

/**
*  Github Search Specific Query Generator
*/
struct GithubSearchQueryGenerator: QueryStringGenerator {
	
	/**
	GithubSearch Query Generator
	
	- parameter source: dictionary with `GithubSearchCondition: String`
	
	- returns: format like `language:Swift+repo:leetcode`
	*/
	func generateQueryStringWithSource(_ source: Any) -> String {
		var retVal = ""
		
		if let conditionDic = source as? [GitHubSearchCondition: String] {
			var queryPair: [String] = []
			for (condition, value) in conditionDic {
				let pair = condition.rawValue + ":" + value
				queryPair.append(pair)
			}
			
			retVal = queryPair.joined(separator: "+")
		}
		
		return retVal
	}
}

internal struct URLQueryEncoding: ParameterEncoding {
	func query(_ parameters: [String: String]) -> String {
		var components: [(String, String)] = []
		
		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			components += githubSearchQueryComponents(key, value)
		}
		
		return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
	}
	
	func encode(_ urlRequest: URLRequestConvertible,
	            with parameters: Parameters?) throws -> URLRequest {
		guard var urlRequest = urlRequest.urlRequest else {
			throw GithubRequestError.InvalidRequest
		}
		if let URLComponents = NSURLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false),
			let validParams = parameters as? [String: String] {
			let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(validParams)
			URLComponents.percentEncodedQuery = percentEncodedQuery
			urlRequest.url = URLComponents.url
		}
		return urlRequest
	}
}

/// Github Search Repo Routes
open class GithubSearchRepoRoutes {
	
	/**
	The sort field. One of stars, forks, or updated. Default: results are sorted by best match.
	*/
	public enum SearchRepoSort: String {
		case Stars = "stars"
		case Forks = "forks"
		case Updated = "updated"
	}
	
	/**
	The sort order if sort parameter is provided. One of asc or desc. Default: desc
	*/
	public enum  SearchRepoOrder: String {
		case Asc = "asc"
		case Desc = "desc"
	}
	
	open unowned let client: GithubNetWorkClient
	init(client: GithubNetWorkClient) {
		self.client = client
	}
	
	/**
	Search Repo for a topic
	
	- parameter topic:         topic to search
	- parameter sort:          sort type
	- parameter order:         order type
	- parameter conditionDict: additional search condition [GitHubSearchCondition: String]
	- parameter page:          page info
	
	- returns: rpc request
	*/
	open func searchRepoForTopic(_ topic: String,
	                             sort: SearchRepoSort = .Updated,
	                             order: SearchRepoOrder = .Desc,
	                             conditionDict: [GitHubSearchCondition: String]? = nil,
	                             page: String = "1") -> RpcCustomResponseRequest<SearchResultSerializer, StringSerializer, String> {
		if topic.characters.count == 0 {
			print(Constants.ErrorInfo.InvalidInput.rawValue)
		}
		var topicQuery = topic
		if let conditions = conditionDict {
			topicQuery += "+" + conditions.queryStringWithGenerator(GithubSearchQueryGenerator())
		}
		
		
		return RpcCustomResponseRequest(client: self.client,
		                                host: "api",
		                                route: "/search/repositories",
		                                method: .get,
		                                params: ["q":topicQuery, "sort": sort.rawValue, "order": order.rawValue, "page":page],
		                                postParams: nil,
		                                postData: nil,
		                                encoding: URLQueryEncoding(),
		                                customResponseHandler: GPHttpResponseHandler.PageHandler,
		                                responseSerializer: SearchResultSerializer(),
		                                errorSerializer: StringSerializer())
	}
}

/// RepoArraySerializer
open class SearchResultSerializer: JSONSerializer {
	let reposSerializer: RepoArraySerializer
	init() {
		self.reposSerializer = RepoArraySerializer()
	}
	
	/**
	descriptions
	*/
	open func serialize(_ value: [GithubRepo]) -> JSON {
		return .null
	}
	
	/**
	JSON -> [GithubRepo]
	*/
	open func deserialize(_ json: JSON) -> [GithubRepo] {
		switch json {
		case .dictionary(let infoDict):
			var retVal: [GithubRepo] = []
			if let items = infoDict["items"] {
				retVal = self.reposSerializer.deserialize(items)
			}
			
			return retVal
		default:
			fatalError("JSON Type should be array")
		}
	}
}



