//
//  TestHelper.swift
//  GithubPilot
//
//  Created by yansong li on 2016-02-20.
//  Copyright © 2016 yansong li. All rights reserved.
//


// Get From: https://github.com/nerdishbynature/octokit.swift
import Foundation

internal class Helper {
	internal class func stringFromFile(_ name: String) -> String? {
		let bundle = Bundle(for: self)
		let path = bundle.path(forResource: name, ofType: "json")
		if let path = path {
			let string = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
			return string
		}
		return nil
	}
	
	internal class func JSONDataFromFile(_ name: String) -> Data? {
		let bundle = Bundle(for: self)
		let path = bundle.path(forResource: name, ofType: "json")!
		let data = try? Data(contentsOf: URL(fileURLWithPath: path))
		return data
	}
}
