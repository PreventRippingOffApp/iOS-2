//
//  HomeViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.layer.cornerRadius = 100
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showMap(_ sender: Any) {
        
    }
    
    @IBAction func emergency(_ sender: Any) {
        
    }
}
