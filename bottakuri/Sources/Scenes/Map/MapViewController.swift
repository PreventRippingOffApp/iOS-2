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
import AVFoundation
import MediaPlayer
import Speech

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVAudioRecorderDelegate {
    
    // Map
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var fillColor: UIColor?
    
    // Parameter Bar
    var progressView:UIProgressView!
    var progress:Float = 0.4
    
    // Record
    var isRecording: Bool = false
    var audioRecorder: AVAudioRecorder?
    var fileArray: [String] = []
    var urlArray: [URL] = []
    var url: URL?
    let userDefaults = UserDefaults.standard
    var isReadForReport: Bool = false
    
    @IBOutlet weak var whiteView: UIView! {
        didSet {
            whiteView.layer.cornerRadius = 20
            whiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            whiteView.frame = CGRect(x:0,y:4*self.view.bounds.maxY/5,width:self.view.bounds.maxX,height:self.view.bounds.maxY/5)
        }
    }
    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
            recordButton.layer.cornerRadius = 20
            recordButton.backgroundColor = UIColor(
                red:1.0, green: 0.0, blue: 0.0, alpha: 0.7)
            recordButton.setTitle("🐱", for: .normal)
            recordButton.layer.position = CGPoint(x: self.view.bounds.midX, y:self.view.bounds.maxY/100)
        }
    }
    @IBOutlet weak var settingButton: UIButton! {
        didSet {
            settingButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
            settingButton.layer.cornerRadius = 3
            settingButton.layer.borderWidth = 1
            settingButton.layer.borderColor = UIColor.black.cgColor
            settingButton.setTitle("設定", for: .normal)
            settingButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            settingButton.layer.position = CGPoint(x: self.view.bounds.midX/2, y:self.view.bounds.maxY/10)
        }
    }
    @IBOutlet weak var recordListButton: UIButton! {
        didSet {
            recordListButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
            recordListButton.layer.cornerRadius = 3
            recordListButton.layer.borderWidth = 1
            recordListButton.layer.borderColor = UIColor.black.cgColor
            recordListButton.setTitle("ログ", for: .normal)
            recordListButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            recordListButton.layer.position = CGPoint(x: 3*self.view.bounds.midX/2, y:self.view.bounds.maxY/10)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        startUpdatingLocation()
        getLocations()
        setProgress()
    }
    
    // MARK: - Map
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
            print(result)
            switch result {
                case .success(let response):
                    self.paintColor(count: response.locationData.count)
                    self.updateProgress(prgCnt: response.locationData.count)
                default:
                    print(result)
                    break
            }
        }
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
    
    // MARK: - Parameter Bar
    func setProgress(){
        progressView = UIProgressView(frame: CGRect(x:0,y:0,width:3*UIScreen.main.bounds.height/5,height:UIScreen.main.bounds.width))
        progressView.center = CGPoint(x: self.view.bounds.maxX-30, y: 5*self.view.bounds.midY/6)
        progressView.progressTintColor = .red
        progressView.setProgress(progress, animated: true)
        progressView.transform = CGAffineTransform(rotationAngle: .pi * -0.5).concatenating(CGAffineTransform(scaleX: 20.0, y: 1.0))
        view.addSubview(progressView)
    }
    
    func updateProgress(prgCnt: Int){
        let prgPercentage:Float = Float(prgCnt / 10)
        progressView.setProgress(prgPercentage, animated: true)
    }
}
