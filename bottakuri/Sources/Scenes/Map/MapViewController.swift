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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var fillColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: false)
            self.userLocation = userLocation
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
    
//    func addPin(location: Location) {
//        let pin: MKPointAnnotation = MKPointAnnotation()
//        pin.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(location.location[0]), CLLocationDegrees(location.location[1]))
//
//        pin.title = location.title
//        pin.subtitle = location.description
//
//        mapView.addAnnotation(pin)
//    }
    
    
    
    func paintColor(count: Int) {
        guard let location = self.userLocation else { return }
        let overlay = MKCircle(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), radius:500)
        if count == 1 {
            self.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 0.5)
        } else if count > 4 {
            self.fillColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 0.5)
        } else {
            self.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 0.5)
        }
        self.mapView.addOverlay(overlay)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = self.fillColor
        renderer.lineWidth = 1.0
        return renderer
    }
    
    func getLocations() {
        guard let location = self.userLocation else { return }
        let request = GetLocations(lat: location.latitude, lng: location.longitude, distance: 1.0)
        Session.send(request) { result in
            switch result {
                case .success(let response):
                    self.paintColor(count: response.locationData.count)
                default:
                    print(result)
                    break
            }
        }
    }
}
