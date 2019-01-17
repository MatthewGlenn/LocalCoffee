//
//  CoffeeShopDownloader.swift
//  LocalCoffee
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import Foundation

//Foursquare API tokens
let ClientID = "PNFFWVDODBS00GSDP05FM4QFU0T45WNWUAOWDDFBSGDGB3FM"
let ClientSecret = "CZEYGXPXTROLNWVIYSMKUA5PWBQJQ4ZXYZRRUNCP2C3BEIZQ"

//Starting Location
let Latitude = 37.775299
let Longitude = -122.398064

/// This Class downloads data from Foursquare for
/// Local Coffee Shops
class Downloader {
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    /// This function returns a url for local coffee shops
    /// Parameter latitude: the latitude to search from
    /// Parameter longitude: the longitude to search from
    /// Returns: url for query of local coffee shops
    func getCoffeeURL(withLatitude latitude: Double, withLongitude longitude: Double)->URL?{
        let urlString = "https://api.foursquare.com/v2/venues/search?client_id=\(ClientID)&client_secret=\(ClientSecret)&v=20180323&limit=15&ll=\(latitude),\(longitude)&query=coffee"
        debugPrint("Foursquare Query: \(urlString)")
        return URL(string: urlString)
    }
    
    
    /// This function downloads Coffee Shops near the location given by the parameters
    /// Parameter latitude: the latitude to download from
    /// Parameter longitude: the longitude to download from
    func downloadCoffeeShops(withLatitude latitude: Double = Latitude, withLongitude longitude: Double = Longitude, completionHander: @escaping () -> Void) {
        //Cancel any previous data tasks
        dataTask?.cancel()
        guard let url = getCoffeeURL(withLatitude: latitude, withLongitude: longitude) else {
            NSLog("Error: Invalid URL")
            return
        }
        
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage += "Error: \(error.localizedDescription) \n"
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                //Parse data
                debugPrint("Downloading Foursquare Data \(data)")
                Parser().parseData(withData: data)
            }
        }
        dataTask?.resume()
    }
    
    /// This method downloads the coffee shop pictures based on the coffee shop photo urls in Core Data
    func downloadCoffeeShopPictures(){
        
    }
}
