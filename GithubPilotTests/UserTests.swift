//
//  UserTests.swift
//  GithubPilot
//
//  Created by yansong li on 2016-02-20.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

import XCTest
@testable import GithubPilot
import Alamofire

class UserTests: XCTestCase {
    var testClient: GithubNetWorkClient!
    var testUserRoutes: UsersRoutes!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(configuration:configuration)
        manager.startRequestsImmediately = false
        testClient = GithubNetWorkClient(manager: manager,
                                       baseHosts: ["api": "https://api.github.com"])
        testUserRoutes = UsersRoutes(client: testClient)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testReadingUserURLRequest() {
        
        let username = "jindulys"
        
        let expectation = self.expectation(description: "\(username)")
        testUserRoutes.getUser(username: username).response({ (result, error) -> Void in
            if let user = result {
                print(user.name)
                print(user.htmlURL)
                XCTAssertEqual(user.login, username)
                expectation.fulfill()
            }
            
            if let rerror = error {
                XCTAssert(false, "Error \(rerror.description)")
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}
