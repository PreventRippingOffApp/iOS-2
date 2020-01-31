//
//  EmergencyViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import APIKit
import SVProgressHUD
import CoreLocation
import MessageUI

class EmergencyViewController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func emergencyCall(_ sender: Any) {
        emergency()
//          sendMail()
    }
    

    
    func emergency() {
        if let number = URL(string: "tel://110"){
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        if let userLocation = locationManager.location?.coordinate {
            let location = Location(description: "", location: [Float(userLocation.latitude), Float(userLocation.longitude)], title: "")
            let request = PostLocation(location: location)
            Session.send(request) { result in
                switch result {
                case .success( _):
                        break
                case .failure( _):
                        break
                }
            }
        }
        let alert = UIAlertController(title: nil, message: "通報しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    
}
