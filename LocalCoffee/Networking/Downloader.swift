//
//  CoffeeShopDownloader.swift
//  LocalCoffee
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import Foundation
import CoreData

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
    var managedObjectContext: NSManagedObjectContext? = nil
    var errorMessage = ""
    /// This function returns a url for local coffee shops
    /// Parameter latitude: the latitude to search from
    /// Parameter longitude: the longitude to search from
    /// Returns: url for query of local coffee shops
    func getVenuesURL(withLatitude latitude: Double, withLongitude longitude: Double)->URL?{
        let urlString = "https://api.foursquare.com/v2/venues/search?client_id=\(ClientID)&client_secret=\(ClientSecret)&v=20180323&limit=15&ll=\(latitude),\(longitude)&query=coffee"
        debugPrint("Foursquare Query: \(urlString)")
        return URL(string: urlString)
    }
    
    /// This function returns a url a specific shop's details
    /// Parameter id: id of the specific shop
    /// Returns: url for query for the specific local coffee shop
    func getPhotoUrl(withID id: String)->URL?{
        let urlString = "https://api.foursquare.com/v2/venues/\(id)/photos?client_id=\(ClientID)&client_secret=\(ClientSecret)&v=20190101"
        debugPrint("Foursquare Venue Details Query: \(urlString)")
        return URL(string: urlString)
    }
    
    /// This function downloads Coffee Shops near the location given by the parameters
    /// Parameter latitude: the latitude to download from
    /// Parameter longitude: the longitude to download from
    func downloadCoffeeShops(withLatitude latitude: Double = Latitude, withLongitude longitude: Double = Longitude) {
        //Cancel any previous data tasks
        dataTask?.cancel()
        guard let url = getVenuesURL(withLatitude: latitude, withLongitude: longitude) else {
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
                Parser().parseDataCoffeeShops(withData: data)
            }
        }
        dataTask?.resume()
    }
    
    func getCoffeeShopPictures(){
        let fetchRequest = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        do {
            //Check for duplicates before adding
            if let coffeeShops = try self.managedObjectContext?.fetch(fetchRequest) {
                for coffeeShop in coffeeShops {
                    if let id = coffeeShop.id {
                        self.downloadCoffeeShopPictures(withID: id)
                    }
                }
            }
            debugPrint("Finished Downloading all coffee shop pictures")
        }catch{
            debugPrint("Error getting CoffeeShops from core data")
        }
        
        NotificationCenter.default.post(name: .NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    /// This method downloads the coffee shop pictures based on the coffee shop photo urls in Core Data
    func downloadCoffeeShopPictures(withID id: String){
//        dataTask?.cancel()
        guard let url = getPhotoUrl(withID: id) else {
            debugPrint("Error: Invalid URL")
            return
        }
        
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription) \n")
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                //Parse data
                debugPrint("Downloading Foursquare Venue Data \(data)")
                Parser().parseDataCoffeeDetails(withData: data, withID: id)
            }
        }
        dataTask?.resume()
    }
}
