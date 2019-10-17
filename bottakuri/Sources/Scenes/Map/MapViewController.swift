//
//  MapViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import APIKit
import SVProgressHUD

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpdatingLocation()
        getLocations()
    }
    
    private func startUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let alert = UIAlertController(title: nil, message: "位置情報の取得に失敗しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func addPin(location: Location) {
        let pin: MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(location.location[0]), CLLocationDegrees(location.location[1]))
        
        pin.title = location.title
        pin.subtitle = location.description
        
        mapView.addAnnotation(pin)
    }
    
    func getLocations() {
        let request = GetLocations()
        Session.send(request) { result in
            switch result {
                case .success(let response):
                    response.locationData.forEach { location in
                        self.addPin(location: location)
                    }
                default:
                    break
            }
        }
    }
}
