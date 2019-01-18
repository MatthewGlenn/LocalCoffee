//
//  CoffeeShopDownloaderTests.swift
//  LocalCoffeeTests
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import XCTest
@testable import LocalCoffee
class DownloaderTests: XCTestCase {
    func testGetVenuesURL_defaultLocation() {
        let latitude:Double = 37.775299
        let longitude:Double = -122.398064
        let expected = URL(string: "https://api.foursquare.com/v2/venues/search?client_id=PNFFWVDODBS00GSDP05FM4QFU0T45WNWUAOWDDFBSGDGB3FM&client_secret=CZEYGXPXTROLNWVIYSMKUA5PWBQJQ4ZXYZRRUNCP2C3BEIZQ&v=20180323&limit=15&ll=\(latitude),\(longitude)&query=coffee")
        let returned = Downloader().getVenuesURL(withLatitude: latitude, withLongitude: longitude)
        XCTAssertEqual(returned, expected, "The expected string:\n\(String(describing: expected))\n, did not match returned string:\n\(String(describing: returned))\n")
    }
    func testGetVenuesURL() {
        let photoID = "123"
        let expected = URL(string: "https://api.foursquare.com/v2/venues/\(123)/photos?client_id=PNFFWVDODBS00GSDP05FM4QFU0T45WNWUAOWDDFBSGDGB3FM&client_secret=CZEYGXPXTROLNWVIYSMKUA5PWBQJQ4ZXYZRRUNCP2C3BEIZQ&v=20190101")
        let returned = Downloader().getPhotoUrl(withID: photoID)
        XCTAssertEqual(returned, expected, "The expected string:\n\(String(describing: expected))\n, did not match returned string:\n\(String(describing: returned))\n")
    }
}
