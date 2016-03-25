//
//  Dictionray+Extensions.swift
//  Pods
//
//  Created by yansong li on 2016-03-24.
//
//

import Foundation

/**
 *  Protocol for generate query string
 */
public protocol QueryStringGenerator {
    /**
     protocol func that use any source to generate a query string, this is an abstraction
     
     - parameter source: source to generate a query string with.
     */
    func generateQueryStringWithSource(source: Any) -> String
}

// MARK: - GithubPilot Dictionary Extension
public extension Dictionary {
    
    /**
     Generate a query string from `self` with generator
     
     - parameter generator: generator that could use dictionary to generate a query String
     */
    public func queryStringWithGenerator(generator: QueryStringGenerator) -> String {
        return generator.generateQueryStringWithSource(self)
    }
}