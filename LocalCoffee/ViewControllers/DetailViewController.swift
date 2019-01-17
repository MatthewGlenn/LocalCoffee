//
//  DetailViewController.swift
//  LocalCoffee
//
//  Created by Matthew Glenn on 1/14/19.
//  Copyright © 2019 Matthew Glenn. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.name!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: CoffeeShop? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

