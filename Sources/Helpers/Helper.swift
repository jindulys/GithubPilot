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
func githubSearchURLQueryEscape(string: String) -> String {
    let generalDelimitersToEncode = ":#[]@"
    
    let subDelimitersToEncode = "!$&'()*,;="
    
    let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
    allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
    
    var escaped = ""
    if #available(iOS 8.3, OSX 10.10, *) {
        escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
            let range = Range(start: startIndex, end: endIndex)
            
            let substring = string.substringWithRange(range)
            escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
            index = endIndex
        }
    }
    return escaped
}

/**
 Creates percent-escaped, URL encoded query string components from the given key-value pair.
 */
func githubSearchQueryComponents(key: String, _ value: String) -> [(String, String)] {
    var components: [(String, String)] = []
    
    components.append((githubSearchURLQueryEscape(key), githubSearchURLQueryEscape(value)))
    
    return components
}