//
//  EmergencyViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit

class EmergencyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func emergencyCall(_ sender: Any) {
        if let number = URL(string: "tel://08036577538"){
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
    }
    
}
