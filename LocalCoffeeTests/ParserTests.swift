//
//  ParserTests.swift
//  LocalCoffeeTests
//
//  Created by Matthew Glenn on 1/18/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import XCTest
@testable import LocalCoffee
class ParserTests: XCTestCase {
    func testUnwrapDictionaryValue_keyExists() {
        let expected = "Some CoffeShop"
        
        let dictionary = ["name":expected] as [String:AnyObject]
        let returned = Parser().unwrapDictionaryValue(withDictionary: dictionary, withKey: "name")
        XCTAssertEqual(expected, returned, "The Expected Dictionary value did not match the returned value")
    }
    
    func testUnwrapDictionaryValue_keyDoesNotExists() {
        let expected = "Some CoffeShop"
        
        let dictionary = ["place":expected] as [String:AnyObject]
        let returned = Parser().unwrapDictionaryValue(withDictionary: dictionary, withKey: "name")
        XCTAssertNotEqual(expected, returned, "The Expected Dictionary value did not match the returned value")
    }
}
