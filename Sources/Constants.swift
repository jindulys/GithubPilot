//
//  Constants.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-19.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/**
 *  Constants used by GithubPilot SDK.
 */
public struct Constants {
    /**
     *  Notification Key
     */
    public struct NotificationKey {
        public static let GithubAccessTokenRequestSuccess = "GithubAccessTokenRequestSuccess"
        public static let GithubAccessTokenRequestFailure = "GithubAccessTokenRequestFailure"
    }
    
    public struct AccessToken {
        public static let GithubAccessTokenStorageKey = "GithubAccessTokenStorageKey"
    }
    
    /**
     ErrorInfo for GithubPilot
     
     - RequestOverTime:  as the name is
     - InvalidInput:     this means your input value is invalid, e.g empty inputs.
     - InvalidOperation: this means the order of your function call is incorrect, check log info.
     */
    public enum ErrorInfo: String {
        case RequestOverTime = "GithubPilot Request Over Time"
        case InvalidInput = "GithubPilot Invalid Input"
        case InvalidOperation = "GithubPilot Invalid Call Order"
    }
}