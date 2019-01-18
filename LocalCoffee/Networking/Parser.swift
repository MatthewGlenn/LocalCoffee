//
//  Parser.swift
//  LocalCoffee
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import Foundation
import CoreData
class Parser {
    var managedObjectContext: NSManagedObjectContext? = nil
    let ImageSize = "100"
    
    func unwrapDictionaryValue(withDictionary dictionary:[String:AnyObject], withKey key:String)->String {
        guard let value = dictionary[key] as? String else {
            debugPrint("Failed to unwrap key: \(key), for dictionary \(dictionary)")
            return ""
        }
        return value
    }
    
    func parseDataCoffeeShops(withData data:Data){
        if self.managedObjectContext == nil {
            self.managedObjectContext = AppDelegate().persistentContainer.viewContext
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            if let response = json["response"] as? [String:AnyObject] {
                if let venues = response["venues"] as? [AnyObject] {
                    for venue in venues {
                        if let venueDictionary = venue as? [String:AnyObject] {
                            let name = unwrapDictionaryValue(withDictionary: venueDictionary, withKey: "name")
                            let id = unwrapDictionaryValue(withDictionary: venueDictionary, withKey: "id")
                            var address = ""
                            if let location = venue["location"] as? [String:AnyObject] {
                                let street = unwrapDictionaryValue(withDictionary: location, withKey: "address")
                                let city = unwrapDictionaryValue(withDictionary: location, withKey: "city")
                                let state = unwrapDictionaryValue(withDictionary: location, withKey: "state")
                                let postalCode = unwrapDictionaryValue(withDictionary: location, withKey: "postalCode")
                                address = "\(street), \(city), \(state), \(postalCode)"
                            }
                            storeElementInCoreData(withName: name, withID: id, withAddress: address)
                        }
                    }
                }
            }
            debugPrint("Finished Downloading Coffee Shops")
            DispatchQueue.global(qos: .userInitiated).async {
                Downloader().getCoffeeShopPictures()
            }
        } catch let error as NSError {
            debugPrint("Failed to load: \(error.localizedDescription)")
        }
    }
    
    func parseDataCoffeeDetails(withData data:Data, withID id: String){
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            if let response = json["response"] as? [String:AnyObject] {
                if let photos = response["photos"] as? [String:AnyObject] {
                    if let items = photos["items"] as? [AnyObject] {
                        if let item = items.first {
                            if let itemDictionary = item as? [String:AnyObject] {
                                let prefix = unwrapDictionaryValue(withDictionary: itemDictionary, withKey: "prefix")
                                let suffix = unwrapDictionaryValue(withDictionary: itemDictionary, withKey: "suffix")
                                if let photoURL = URL(string: "\(prefix)\(ImageSize)x\(ImageSize)\(suffix)") {
                                    storeImage(withURL: photoURL, withID: id)
                                }
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            debugPrint("Failed to load: \(error.localizedDescription)")
        }
    }
    
    func storeImage(withURL url: URL, withID id: String){
        if self.managedObjectContext == nil {
            self.managedObjectContext = AppDelegate().persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            //Check for duplicates before adding
            let coffeeShops = try self.managedObjectContext?.fetch(fetchRequest)
            if coffeeShops?.count == 1, let coffeeShop = coffeeShops?.first {
                coffeeShop.setValue(url, forKey: "photoURL")
                let tempData = try! Data(contentsOf: url)
                coffeeShop.setValue(tempData, forKey: "photo")
            }
        }catch{
            debugPrint("Error adding images to core data")
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func storeElementInCoreData(withName name: String, withID id: String, withAddress address: String){
        if self.managedObjectContext == nil {
            self.managedObjectContext = AppDelegate().persistentContainer.viewContext
        }
        let entity = NSEntityDescription.entity(forEntityName: "CoffeeShop", in: self.managedObjectContext!)
        
        let fetchRequest = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            //Check for duplicates before adding
            let coffeeShops = try self.managedObjectContext?.fetch(fetchRequest)
            if coffeeShops!.count == 0 {
                let coffeeShop = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                coffeeShop.setValue(name, forKeyPath: "name")
                coffeeShop.setValue(id, forKeyPath: "id")
                coffeeShop.setValue(address, forKeyPath: "address")
            }
        }catch{
            debugPrint("Error adding shops to core data")
        }
        
        do {
            try self.managedObjectContext!.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
}
