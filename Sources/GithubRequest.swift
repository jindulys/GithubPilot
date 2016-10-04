//
//  Request.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-16.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import Alamofire

open class GithubNetWorkClient {
	var manager: Alamofire.SessionManager
	var baseHosts: [String: String]
	
	func additionalHeaders(_ needoauth: Bool) -> [String: String] {
		return [:]
	}
	
	init(manager: Alamofire.SessionManager, baseHosts: [String: String]) {
		self.manager = manager
		self.baseHosts = baseHosts
	}
}

func utf8Decode(_ data: Data) -> String {
	return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
}

open class Box<T> {
	open let value: T
	init(_ value: T) {
		self.value = value
	}
}

/// A Custom ParameterEncoding Structure encoding JSON Params.
internal struct JSONPostEncoding: ParameterEncoding {
	let postJSONParams: JSON
	
	init(json: JSON) {
		self.postJSONParams	= json
	}
	
	
	func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
		guard var urlRequest = urlRequest.urlRequest else {
			throw GithubRequestError.InvalidRequest
		}
		urlRequest.httpBody = dumpJSON(postJSONParams)
		return urlRequest
	}
}

internal struct DataPostEncoding: ParameterEncoding {
	let postData: Data
	
	init(data: Data) {
		self.postData = data
	}
	
	func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
		guard var urlRequest = urlRequest.urlRequest else {
			throw GithubRequestError.InvalidRequest
		}
		let length = postData.count
		urlRequest.setValue("\(length)", forHTTPHeaderField: "Content-Length")
		urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		urlRequest.httpBody = postData
		return urlRequest
	}
}

public enum RequestError<EType> : CustomStringConvertible {
	case badRequest(Int, Box<EType>)
	case internalServerError(Int, String?)
	case rateLimitError
	case httpError(Int?, String?)
	
	public var description: String {
		switch self {
		case let .badRequest(code, box):
			var ret = ""
			ret += "Bad Request - Code: \(code)"
			ret += " : \(box.value)"
			return ret
		case let .internalServerError(code, message):
			var ret = ""
			ret += "Internal Server Error: \(code)"
			if let m = message {
				ret += " : \(m)"
			}
			return ret
		case .rateLimitError:
			return "Rate limited"
		case let .httpError(code, message):
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

public enum GithubRequestError: Error {
	case InvalidRequest
}

/// Represents a request object
///
/// Pass in a closure to the `response` method to handle a response or error.
open class GithubRequest<RType: JSONSerializer, EType: JSONSerializer> {
	let responseSerializer: RType
	let errorSerializer: EType
	let request: Alamofire.DataRequest
	
	init(request: Alamofire.DataRequest, responseSerializer: RType, errorSerializer: EType) {
		self.request = request
		self.responseSerializer = responseSerializer
		self.errorSerializer = errorSerializer
	}
	
	func handleResponseError(_ response: HTTPURLResponse?,
	                         data: Data?,
	                         error: Error?) -> RequestError<EType.ValueType> {
		if let code = response?.statusCode {
			switch code {
			case 500...599:
				var message = ""
				if let d = data {
					message = utf8Decode(d)
				}
				return .internalServerError(code, message)
			case 429:
				return .rateLimitError
			case 400, 403, 404, 422:
				if let d = data {
					let messageJSON = parseJSON(d)
					switch messageJSON {
					case .dictionary(let dic):
						let message = self.errorSerializer.deserialize(dic["message"]!)
						return .badRequest(code, Box(message))
					default:
						fatalError("Failed to parse error type")
					}
				}
				fatalError("Failed to parse error type")
			default:
				return .httpError(code, "HTTP Error")
			}
		} else {
			var message = ""
			if let d = data {
				message = utf8Decode(d)
			}
			return .httpError(nil, message)
		}
	}
}

/// A Request Object could directly use `API url`, provided by Github
open class DirectAPIRequest<RType: JSONSerializer, EType: JSONSerializer>: GithubRequest<RType, EType> {
	/**
	Initialize a DirectAPIRequest Object
	
	- parameter apiURL:             An API URL provided by some Github JSON response.
	
	*/
	init(client:GithubNetWorkClient,
	     apiURL: String,
	     method: Alamofire.HTTPMethod,
	     params:[String: String] = ["": ""],
	     responseSerializer: RType,
	     errorSerializer: EType) {
		var headers = ["Content-Type": "application/json"]
		for (header, val) in client.additionalHeaders(true) {
			headers[header] = val
		}
		let request = client.manager.request(apiURL, method:method, parameters: params, headers: headers)
		super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
		request.resume()
	}
	
	/**
	Response function for DirectAPIRequest.
	
	- parameter complitionHandler: complitionHandler.
	
	- returns: self.
	*/
	@discardableResult
	open func response(_ complitionHandler:@escaping (RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
		self.request.validate().response { response in
			let d = response.data!
			if let error = response.error, let response = response.response {
				complitionHandler(nil, self.handleResponseError(response, data: d, error: error))
			} else {
				complitionHandler(self.responseSerializer.deserialize(parseJSON(d)), nil)
			}
		}
		return self
	}
}

/// An "rpc-style" request
open class RpcRequest<RType: JSONSerializer, EType: JSONSerializer>: GithubRequest<RType, EType> {
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
	init(client: GithubNetWorkClient,
	     host: String, route: String,
	     method: Alamofire.HTTPMethod,
	     params:[String: String] = ["": ""],
	     postParams: JSON? = nil,
	     postData: Data? = nil,
	     encoding: ParameterEncoding = URLEncoding.default,
	     responseSerializer: RType,
	     errorSerializer: EType) {
		let url = "\(client.baseHosts[host]!)\(route)"
		var headers = ["Content-Type": "application/json"]
		let needOauth = (host == "api")
		for (header, val) in client.additionalHeaders(needOauth) {
			headers[header] = val
		}
		
		var request: Alamofire.DataRequest
		switch method {
		case .get:
			request = client.manager.request(url,
			                                 method: .get,
			                                 parameters: params,
			                                 encoding: encoding,
			                                 headers: headers)
		case .post:
			if let pParams = postParams {
				request = client.manager.request(url,
				                                 method: .post,
				                                 parameters: ["": ""],
				                                 encoding: JSONPostEncoding(json: pParams),
				                                 headers: headers)
			} else if let pData = postData {
				request = client.manager.request(url,
				                                 method: .post,
				                                 parameters: ["": ""],
				                                 encoding: DataPostEncoding(data: pData),
				                                 headers: headers)
			} else {
				request = client.manager.request(url,
				                                 method: .post,
				                                 parameters: ["": ""],
				                                 headers: headers)
			}
		default:
			fatalError("Wrong RpcRequest Method Type, should only be \"GET\" \"POST\"")
		}
		
		super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
		request.resume()
	}
	
	/**
	Response function for RpcRequest.
	
	- parameter complitionHandler: complitionHandler.
	
	- returns: self.
	*/
	@discardableResult
	open func response(_ complitionHandler:@escaping (RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
		self.request.validate().response { response in
			let d = response.data!
			if let error = response.error, let response = response.response {
				complitionHandler(nil, self.handleResponseError(response, data: d, error:error))
			} else {
				complitionHandler(self.responseSerializer.deserialize(parseJSON(d)), nil)
			}
		}
		return self
	}
}

/// An "rpc-style" request, which has a `httpResponseHandler` that could do some custom operation with HTTPResponse Header.
open class RpcCustomResponseRequest<RType: JSONSerializer, EType: JSONSerializer, T>: RpcRequest<RType, EType> {
	var httpResponseHandler: ((HTTPURLResponse?)->T?)?
	// DefaultResponseQueue, set this if you want your response return to queue other than main queue.
	var defaultResponseQueue: DispatchQueue?
	
	/**
	Designated Initializer
	
	- parameter customResponseHandler: custom handler to deal with HTTPURLResponse, usually you want to use this to extract info from Response's allHeaderFields.
	- parameter defaultResponseQueue : The queue you want response block to be executed on.
	*/
	init(client: GithubNetWorkClient,
	     host: String,
	     route: String,
	     method: Alamofire.HTTPMethod,
	     params: [String: String] = ["": ""],
	     postParams: JSON? = nil,
	     postData: Data? = nil,
	     encoding: ParameterEncoding = URLEncoding.default,
	     customResponseHandler: ((HTTPURLResponse?)->T?)? = nil,
	     defaultResponseQueue: DispatchQueue? = nil, responseSerializer: RType, errorSerializer: EType) {
		httpResponseHandler = customResponseHandler
		self.defaultResponseQueue = defaultResponseQueue
		super.init(client: client,
		           host: host,
		           route: route,
		           method: method,
		           params: params,
		           postParams: postParams,
		           postData: postData,
		           encoding: encoding,
		           responseSerializer: responseSerializer,
		           errorSerializer: errorSerializer)
	}
	
	/**
	Response function for RpcCustomResponseRequest.
	
	- parameter complitionHandler: complitionHandler.
	
	- returns: self.
	*/
	@discardableResult
	open func response(_ complitionHandler:@escaping (T?, RType.ValueType?, RequestError<EType.ValueType>?) -> Void) -> Self {
		self.request.validate().response(queue: defaultResponseQueue) { response in
			let d = response.data!
			let responseResult = self.httpResponseHandler?(response.response)
			if let error = response.error, let response = response.response {
				complitionHandler(responseResult, nil, self.handleResponseError(response, data: d, error:error))
			} else {
				complitionHandler(responseResult, self.responseSerializer.deserialize(parseJSON(d)), nil)
			}
		}
		return self
	}
}

