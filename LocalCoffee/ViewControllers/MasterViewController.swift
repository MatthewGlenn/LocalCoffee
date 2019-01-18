//
//  MasterViewController.swift
//  LocalCoffee
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        DispatchQueue.global(qos: .userInitiated).async {
            Downloader().downloadCoffeeShops()
        }
    }
    
    @objc func update(){
        DispatchQueue.global(qos: .userInitiated).async  {
            do {
                try self._fetchedResultsController?.performFetch()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }catch{
                debugPrint("Failed To Fetch Results")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let coffeeShop = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withCoffeeShop: coffeeShop)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    func configureCell(_ cell: UITableViewCell, withCoffeeShop coffeeShop: CoffeeShop) {
        cell.textLabel!.text = coffeeShop.name!.description
        cell.detailTextLabel?.text = coffeeShop.address!.description
        if let imageData = coffeeShop.photo, let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        }else{
            cell.imageView?.image = UIImage(named: "Placeholder")
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<CoffeeShop> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<CoffeeShop> = CoffeeShop.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 15
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<CoffeeShop>? = nil

    private func controllerWillChangeContent(_ controller: NSFetchedResultsController<CoffeeShop>) {
        tableView.beginUpdates()
    }

    private func controller(_ controller: NSFetchedResultsController<CoffeeShop>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    private func controller(_ controller: NSFetchedResultsController<CoffeeShop>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCoffeeShop: anObject as! CoffeeShop)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCoffeeShop: anObject as! CoffeeShop)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
