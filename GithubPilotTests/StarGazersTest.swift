//
//  StarGazersTest.swift
//  GithubPilot
//
//  Created by yansong li on 2016-02-24.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

import XCTest
@testable import GithubPilot
import Alamofire

class StarGazersTests: XCTestCase {
	var testClient: GithubNetWorkClient!
	var testStarsRoutes: StarsRoutes!
	
	override func setUp() {
		super.setUp()
		
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
		let manager = Alamofire.SessionManager(configuration:configuration)
		manager.startRequestsImmediately = false
		testClient = GithubNetWorkClient(manager: manager,
		                                 baseHosts: ["api": "https://api.github.com"])
		testStarsRoutes = StarsRoutes(client: testClient)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testWrongParameterStarGazerRequest() {
		
		let username = "jindulys"
		
		let expectation = self.expectation(description: "WrongParameter")
		testStarsRoutes.getAllStargazersFor(repo: "Hackerlala", owner: username) {
			result, error in
			if let error = error {
				XCTAssertEqual(error, "Bad Request - Code: 404 : Not Found")
				expectation.fulfill()
			} else {
				XCTAssert(false, "Should be error")
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: 5) { (error) in
			XCTAssertNil(error, "\(error)")
		}
	}
	
	func testStarGazerCountRequest() {
		
		let username = "jindulys"
		
		let expectation = self.expectation(description: "StarGazerCount")
		testStarsRoutes.getAllStargazersFor(repo: "HackerRankSolutions", owner: username) {
			result, error in
			if let _ = error {
				XCTAssert(false, "Failed Test")
				expectation.fulfill()
			} else {
				if let followers = result {
					XCTAssert(followers.count > 100)
				}
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: 20) { (error) in
			XCTAssertNil(error, "\(error)")
		}
	}
	
}
