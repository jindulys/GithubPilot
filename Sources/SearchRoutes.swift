//
//  SearchRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-03-23.
//
//

import Foundation


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
    case Stars = "Stars"
    
    // Sepecific for Search Code
    case Extension = "extension"
    case FileName = "filename"
    case Path = "path"
    
    // Sepecific for Search Users
    case Type = "type"
    case Repos = "repos"
    case Location = "Location"
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
    func generateQueryStringWithSource(source: Any) -> String {
        var retVal = ""
        
        if let conditionDic = source as? [GitHubSearchCondition: String] {
            var queryPair: [String] = []
            for (condition, value) in conditionDic {
                let pair = condition.rawValue + ":" + value
                queryPair.append(pair)
            }
            
            retVal = queryPair.joinWithSeparator("+")
        }
        
        return retVal
    }
}

/// Github Search Repo Routes
public class GithubSearchRepoRoutes {
    
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
    
    public unowned let client: GithubNetWorkClient
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
    public func searchRepoForTopic(topic: String, sort: SearchRepoSort = .Updated, order: SearchRepoOrder = .Desc, conditionDict: [GitHubSearchCondition: String]? = nil, page: String = "1") -> RpcCustomResponseRequest<SearchResultSerializer, StringSerializer, String> {
        if topic.characters.count == 0 {
            print(Constants.ErrorInfo.InvalidInput.rawValue)
        }
        
        let httpResponseHandler:(NSHTTPURLResponse?) -> String? = { (response: NSHTTPURLResponse?) in
            if let nonNilResponse = response,
                link = (nonNilResponse.allHeaderFields["Link"] as? String),
                sinceRange = link.rangeOfString("page=") {
                    var retVal = ""
                    var checkIndex = sinceRange.endIndex
                    
                    while checkIndex != link.endIndex {
                        let character = link.characters[checkIndex]
                        let characterInt = character.zeroCharacterBasedunicodeScalarCodePoint()
                        if characterInt>=0 && characterInt<=9 {
                            retVal += String(character)
                        } else {
                            break
                        }
                        checkIndex = checkIndex.successor()
                    }
                    return retVal
            }
            return nil
        }
        
        var topicQuery = topic
        
        if let conditions = conditionDict {
            topicQuery += "+" + conditions.queryStringWithGenerator(GithubSearchQueryGenerator())
        }
        
        
        return RpcCustomResponseRequest(client: self.client,
            host: "api",
            route: "/search/repositories",
            method: .GET,
            params: ["q":topicQuery, "sort": sort.rawValue, "order": order.rawValue, "page":page],
            postParams: nil,
            postData: nil,
            customResponseHandler: httpResponseHandler,
            responseSerializer: SearchResultSerializer(),
            errorSerializer: StringSerializer())
    }
}

/// RepoArraySerializer
public class SearchResultSerializer: JSONSerializer {
    let reposSerializer: RepoArraySerializer
    init() {
        self.reposSerializer = RepoArraySerializer()
    }
    
    /**
     descriptions
     */
    public func serialize(value: [GithubRepo]) -> JSON {
        return .Null
    }
    
    /**
     JSON -> [GithubRepo]
     */
    public func deserialize(json: JSON) -> [GithubRepo] {
        switch json {
        case .Dictionary(let infoDict):
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



