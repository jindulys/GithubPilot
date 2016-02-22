//
//  Request.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-16.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

public class GithubNetWorkClient {
    var manager: Alamofire.Manager
    var baseHosts: [String: String]
    
    func additionalHeaders(needoauth: Bool) -> [String: String] {
        return [:]
    }
    
    init(manager: Alamofire.Manager, baseHosts: [String: String]) {
        self.manager = manager
        self.baseHosts = baseHosts
    }
}

func utf8Decode(data: NSData) -> String {
    return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
}

public class Box<T> {
    public let value: T
    init(_ value: T) {
        self.value = value
    }
}

public enum RequestError<EType> : CustomStringConvertible {
    case BadRequest(Int, Box<EType>)
    case InternalServerError(Int, String?)
    case RateLimitError
    case HTTPError(Int?, String?)
    
    public var description: String {
        switch self {
            case let .BadRequest(code, box):
                var ret = ""
                ret += "Bad Request - Code: \(code)"
                ret += " : \(box.value)"
                return ret
            case let .InternalServerError(code, message):
                var ret = ""
                ret += "Internal Server Error: \(code)"
                if let m = message {
                    ret += " : \(m)"
                }
                return ret
            case .RateLimitError:
                return "Rate limited"
            case let .HTTPError(code, message):
                var ret = "HTTP Error"
                if let c = code {
                    ret += " code: \(c)"
                }
                if let m = message {
                    ret += " : \(m)"
                }
                return ret
        }
    }
}


/// Represents a request object
///
/// Pass in a closure to the `response` method to handle a response or error.
public class GithubRequest<RType: JSONSerializer, EType: JSONSerializer> {
    let responseSerializer: RType
    let errorSerializer: EType
    let request: Alamofire.Request
    
    init(request: Alamofire.Request, responseSerializer: RType, errorSerializer: EType) {
        self.request = request
        self.responseSerializer = responseSerializer
        self.errorSerializer = errorSerializer
    }
    
    func handleResponseError(response: NSHTTPURLResponse?, data: NSData?, error:ErrorType?) -> RequestError<EType.ValueType> {
        if let code = response?.statusCode {
            switch code {
                case 500...599:
                    var message = ""
                    if let d = data {
                        message = utf8Decode(d)
                    }
                    return .InternalServerError(code, message)
                case 429:
                    return .RateLimitError
                case 400, 403, 404, 422:
                    if let d = data {
                        let messageJSON = parseJSON(d)
                        switch messageJSON {
                            case .Dictionary(let dic):
                                let message = self.errorSerializer.deserialize(dic["message"]!)
                                return .BadRequest(code, Box(message))
                            default:
                                fatalError("Failed to parse error type")
                        }
                    }
                    fatalError("Failed to parse error type")
                default:
                    return .HTTPError(code, "HTTP Error")
            }
        } else {
            var message = ""
            if let d = data {
                message = utf8Decode(d)
            }
            return .HTTPError(nil, message)
        }
    }
}

/// A Request Object could directly use `API url`, provided by Github 
public class DirectAPIRequest<RType: JSONSerializer, EType: JSONSerializer>: GithubRequest<RType, EType> {
    /**
      Initialize a DirectAPIRequest Object

     - parameter apiURL:             An API URL provided by some Github JSON response.

     */
    init(client:GithubNetWorkClient, apiURL: String, method: Alamofire.Method, params:[String: String] = ["": ""],responseSerializer: RType, errorSerializer: EType) {
        var headers = ["Content-Type": "application/json"]
        for (header, val) in client.additionalHeaders(true) {
            headers[header] = val
        }
        
        let request = client.manager.request(method, apiURL, parameters: params, headers: headers)
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
        request.resume()
    }
    
    public func response(complitionHandler:(RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, data, error) -> Void in
            let d = data!
            if error != nil {
                complitionHandler(nil, self.handleResponseError(response, data: d, error:error))
            } else {
                complitionHandler(self.responseSerializer.deserialize(parseJSON(d)), nil)
            }
        }
        return self
    }
}

/// An "rpc-style" request
public class RpcRequest<RType: JSONSerializer, EType: JSONSerializer>: GithubRequest<RType, EType> {
    /**
     Initialize a RpcRequest Object
     
     - parameter client:             Client to get URL Host.
     - parameter host:               host key to get from client.
     - parameter route:              url path.
     - parameter method:             HTTP Method.
     - parameter params:             url parameters.
     - parameter postParams:         HTTP Body parameters used for POST Request.
     - parameter postData:           HTTP Body parameters used with NSData format.
     - parameter responseSerializer: responseSerializer used to generate response object.
     - parameter errorSerializer:    errorSerializer.
     
     - returns: an initialized RpcRequest.
     */
    init(client: GithubNetWorkClient, host: String, route: String, method: Alamofire.Method, params:[String: String] = ["": ""], postParams: JSON? = nil, postData: NSData? = nil, responseSerializer: RType, errorSerializer: EType) {
        let url = "\(client.baseHosts[host]!)\(route)"
        var headers = ["Content-Type": "application/json"]
        let needOauth = (host == "api")
        for (header, val) in client.additionalHeaders(needOauth) {
            headers[header] = val
        }
        
        var request: Alamofire.Request
        switch method {
            case .GET:
                request = client.manager.request(.GET, url, parameters: params, headers: headers)
            case .POST:
                if let pParams = postParams {
                    request = client.manager.request(.POST, url, parameters: ["": ""], headers: headers, encoding: ParameterEncoding.Custom({ (convertible, _) -> (NSMutableURLRequest, NSError?) in
                        let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                        mutableRequest.HTTPBody = dumpJSON(pParams)
                        return (mutableRequest, nil)
                    }))
                } else if let pData = postData {
                    request = client.manager.request(.POST, url, parameters: ["": ""], headers: headers, encoding: ParameterEncoding.Custom({ (convertible, _) -> (NSMutableURLRequest, NSError?) in
                        let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                        let length = pData.length
                        mutableRequest.setValue("\(length)", forHTTPHeaderField: "Content-Length")
                        mutableRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        mutableRequest.HTTPBody = pData
                        return (mutableRequest, nil)
                    }))
                } else {
                    request = client.manager.request(.POST, url, parameters: ["": ""], headers: headers)
                }
            default:
                fatalError("Wrong RpcRequest Method Type, should only be \"GET\" \"POST\"")
        }
        
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
        request.resume()
    }
    
    public func response(complitionHandler:(RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, data, error) -> Void in
            let d = data!
            if error != nil {
                complitionHandler(nil, self.handleResponseError(response, data: d, error:error))
            } else {
                complitionHandler(self.responseSerializer.deserialize(parseJSON(d)), nil)
            }
        }
        return self
    }
}

/// An "rpc-style" request
public class RpcCustomResponseRequest<RType: JSONSerializer, EType: JSONSerializer, T>: RpcRequest<RType, EType> {
    var httpResponseHandler: ((NSHTTPURLResponse?)->T?)?
    
    /**
     Designated Initializer
     
     - parameter customResponseHandler: custom handler to deal with HTTPURLResponse, usually you want to use this to extract info from Response's allHeaderFields.
     */
    init(client: GithubNetWorkClient, host: String, route: String, method: Alamofire.Method, params:[String: String] = ["": ""], postParams: JSON? = nil, postData: NSData? = nil, customResponseHandler:((NSHTTPURLResponse?)->T?)? = nil, responseSerializer: RType, errorSerializer: EType) {
        httpResponseHandler = customResponseHandler
        super.init(client: client, host: host, route: route, method: method, params: params, postParams: postParams, postData: postData, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }
    
    public func response(complitionHandler:(T?, RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, data, error) -> Void in
            let d = data!
            let responseResult = self.httpResponseHandler?(response)
            if error != nil {
                complitionHandler(responseResult, nil, self.handleResponseError(response, data: d, error:error))
            } else {
                complitionHandler(responseResult, self.responseSerializer.deserialize(parseJSON(d)), nil)
            }
        }
        return self
    }
}

