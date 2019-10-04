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

class EmergencyViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func emergencyCall(_ sender: Any) {
        emergency()
    }
    
    func emergency() {
//        if let number = URL(string: "tel://110"){
//            UIApplication.shared.open(number, options: [:], completionHandler: nil)
//        }
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
                print(result)
                switch result {
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        print(error)
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
