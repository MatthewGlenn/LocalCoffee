//
//  ParserTests.swift
//  LocalCoffeeTests
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import XCTest
@testable import LocalCoffee
class ParserTests: XCTestCase {
    func getArrayOfElementsFromCoreData()->[CoffeeShop]{
        return [CoffeeShop]()
    }
    func testParseData(){
        Parser().parseFromStoredJSON()
//        let expected = [CoffeeShop(context: <#T##NSManagedObjectContext#>)]
//        let returned = getArrayOfElementsFromCoreData()
//
//        guard expected.count == returned.count else {
//            XCTFail("The expected number of shops did not match the returned number")
//            return
//        }
//
//        for i in 0..<expected.count {
//            XCTAssertEqual(expected[i].name, returned[i].name)
//            XCTAssertEqual(expected[i].address, returned[i].address)
//            XCTAssertEqual(expected[i].photoURL, returned[i].photoURL)
//            XCTAssertEqual(expected[i].rating, returned[i].rating)
//        }
    }
}
