//
//  HomeViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var isRecording: Bool = false

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var recordButton: UIButton! 
    
    @IBOutlet weak var mapButton: UIButton! {
        didSet {
            mapButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var emergencyButton: UIButton! {
        didSet {
            emergencyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showMap(_ sender: Any) {
        let mapStoryBoard: UIStoryboard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewContorller: MapViewController = mapStoryBoard.instantiateViewController(withIdentifier: "Map") as! MapViewController
        self.navigationController?.pushViewController(mapViewContorller, animated: true)
    }
    
    @IBAction func emergency(_ sender: Any) {
        let emergencyStoryBoard: UIStoryboard = UIStoryboard(name: "Emergency", bundle: nil)
        let emergencyViewContorller: EmergencyViewController = emergencyStoryBoard.instantiateViewController(withIdentifier: "Emergency") as! EmergencyViewController
        self.navigationController?.pushViewController(emergencyViewContorller, animated: true)
    }
    
    @IBAction func record(_ sender: Any) {
        if isRecording {
            isRecording = false
            self.recordButton.layer.cornerRadius = 100
        } else {
            isRecording = true
            self.recordButton.layer.cornerRadius = 0
        }
        
    }
}

class circleButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }
}
