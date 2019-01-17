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
    /// Method for parsing locally stored JSON for test purposes
    func parseFromStoredJSON(){
        
    }
    
    func unwrapDictionaryValue(withDictionary dictionary:[String:AnyObject], withKey key:String)->String {
        guard let value = dictionary[key] as? String else {
            debugPrint("Failed to unwrap key: \(key), for dictionary \(dictionary)")
            return ""
        }
        return value
    }
    
    func parseData(withData data:Data){
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
        } catch let error as NSError {
            debugPrint("Failed to load: \(error.localizedDescription)")
        }
    }
    
    func storeElementInCoreData(withName name: String, withID id: String, withAddress address: String){
        let managedObjectContext = AppDelegate().persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CoffeeShop", in: managedObjectContext)!
        
        let fetchRequest = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            //Check for duplicates before adding
            let coffeeShops = try managedObjectContext.fetch(fetchRequest)
            if coffeeShops.count == 0 {
                let coffeeShop = NSManagedObject(entity: entity, insertInto: managedObjectContext)
                
                coffeeShop.setValue(name, forKeyPath: "name")
                coffeeShop.setValue(id, forKeyPath: "id")
                coffeeShop.setValue(address, forKeyPath: "address")
            }
        }catch{
            debugPrint("Error adding shops to core data")
        }
        
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
}
