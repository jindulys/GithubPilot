//
//  Constants.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

public struct Constants {
    public struct NotificationKey {
        public static let GithubAccessTokenRequestSuccess = "GithubAccessTokenRequestSuccess"
        public static let GithubAccessTokenRequestFailure = "GithubAccessTokenRequestFailure"
    }
    
    public struct AccessToken {
        public static let GithubAccessTokenStorageKey = "GithubAccessTokenStorageKey"
    }
    
    public enum ErrorInfo: String {
        case RequestOverTime = "GithubPilot Request Over Time"
        case InvalidInput = "GithubPilot Invalid Input"
        case InvalidOperation = "GithubPilot Invalid Call Order"
    }
}