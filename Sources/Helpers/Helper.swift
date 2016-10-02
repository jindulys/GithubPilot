//
//  Helper.swift
//  Pods
//
//  Created by yansong li on 2016-03-25.
//
//

import Foundation

/**
 Special URL query escape for `GithubSearch`, this one will not escape `+`, otherwise search could not wokr.
 
 - parameter string: The string to be percent-escaped.
 
 - returns: The percent-escaped string.
 */
func githubSearchURLQueryEscape(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@"
    
    let subDelimitersToEncode = "!$&'()*,;="
    
    let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
    
    var escaped = ""
    if #available(iOS 10.0, OSX 10.12, *) {
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
					let startIndex = index
					var endIndex: String.Index
					if let batchedEndIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) {
						endIndex = batchedEndIndex
					} else {
						endIndex = string.endIndex
					}
					let range = (startIndex ..< endIndex)
					let substring = string.substring(with: range)
					escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? substring
					index = endIndex
        }
    }
    return escaped
}

/**
 Creates percent-escaped, URL encoded query string components from the given key-value pair.
 */
func githubSearchQueryComponents(_ key: String, _ value: String) -> [(String, String)] {
    var components: [(String, String)] = []
    
    components.append((githubSearchURLQueryEscape(key), githubSearchURLQueryEscape(value)))
    
    return components
}
