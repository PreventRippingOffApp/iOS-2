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
import MessageUI

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVAudioRecorderDelegate,MFMailComposeViewControllerDelegate {
    
    // Map
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var fillColor: UIColor?
    var deferringUpdates = false
    
    // Parameter Bar
    var progressView:UIProgressView!
    var progress:Float = 0.0
    
    // Record
    var isRecording: Bool = false
    var audioRecorder: AVAudioRecorder?
    var fileArray: [String] = []
    var urlArray: [URL] = []
    var url: URL?
    let userDefaults = UserDefaults.standard
    var isReadForReport: Bool = false
    
    // Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var audioEngine = AVAudioEngine()
    private var inputText: String = ""
    
    @IBOutlet weak var whiteView: UIView! {
        didSet {
            whiteView.layer.cornerRadius = 20
            whiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.layer.cornerRadius = 20
            recordButton.backgroundColor = UIColor(
                red:1.0, green: 0.0, blue: 0.0, alpha: 0.7)
            recordButton.setTitle("🐱", for: .normal)
        }
    }
    @IBOutlet weak var settingButton: UIButton! {
        didSet {
            settingButton.layer.cornerRadius = 3
            settingButton.layer.borderWidth = 1
            settingButton.layer.borderColor = UIColor.black.cgColor
            settingButton.setTitle("設定", for: .normal)
            settingButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
    }
    @IBOutlet weak var recordListButton: UIButton! {
        didSet {
            recordListButton.layer.cornerRadius = 3
            recordListButton.layer.borderWidth = 1
            recordListButton.layer.borderColor = UIColor.black.cgColor
            recordListButton.setTitle("ログ", for: .normal)
            recordListButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUI()
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                        switch status {
                        case .authorized:   // 許可OK
                            self.recordButton.isEnabled = true
                        default:
                            self.recordButton.isEnabled = false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        startUpdatingLocation()
        getLocations()
        getRisk()
        setProgress()
        guard let fileArray = self.userDefaults.array(forKey: "fileArray") else { return }
        for file in fileArray {
            let url = self.userDefaults.url(forKey: file as! String)
            self.urlArray.append(url!)
        }
        
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if error != nil {
                    return
                }

                if granted {
                    print("通知許可")

                    let center = UNUserNotificationCenter.current()
                    center.delegate = self

                } else {
                    print("通知拒否")
                }
            })

        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
//        locationManager.distanceFilter = 100
//        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Map
    @objc private func locationUpdate() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
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
                    self.updateProgress(prgCnt: response.locationData.count)
                default:
                    print(result)
                    break
            }
        }
    }
    
    func getRisk() {
        guard let location = self.userLocation else { return }
        let request = GetRisk(lat: location.latitude, lng: location.longitude)
        Session.send(request) { result in
            switch result {
                case .success(let response):
                    self.updateProgress(prgCnt: response.risk)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        if let last = lastLocation {
            let eventDate = last.timestamp
            if abs(eventDate.timeIntervalSinceNow) < 15.0 {
                if let location = manager.location {
                    let request = GetRisk(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                    Session.send(request) { result in
                        switch result {
                            case .success(let response):
                                print(response)
                                if response.risk > 5 {
                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                    
                                    let content = UNMutableNotificationContent()
                                    content.title = "警告"
                                    content.body = "危険なエリアに入りました"
                                    content.sound = UNNotificationSound.default
                                    
                                    let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
                                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                }
                            case .failure(let error):
                                print(error)
                        }
                    }
                }
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
    
    // MARK: - UI Process
    
    @IBAction func record(_ sender: Any) {
        if isRecording {
            guard let audioRecorder = self.audioRecorder else { fatalError("レコーダが見つかりませんでした") }
            audioRecorder.stop()
            userDefaults.set(self.fileArray, forKey: "fileArray")
            userDefaults.set(self.url, forKey: fileArray.last!)
            self.recognitionTask?.cancel()
            self.recognitionTask?.finish()
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            print("stop")
            isRecording = false
        } else {
            let session = AVAudioSession.sharedInstance()
                       
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
            } catch  {
               fatalError("category err")
            }

            do {
               try session.setActive(true)
            } catch {
               fatalError("session activate err")
            }

            let settings = [
               AVFormatIDKey: Int(kAudioFormatFLAC),
               AVSampleRateKey: 44100,
               AVNumberOfChannelsKey: 1,
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                self.audioRecorder = try AVAudioRecorder(url: getURL(), settings: settings)
            } catch {
                self.audioRecorder = nil
            }
            guard let audioRecorder = self.audioRecorder else { fatalError("recorder生成エラー") }
            audioRecorder.delegate = self
            audioRecorder.record()
            try! startRecording()
            print("start")
            isRecording = true
        }
    }
    
    @IBAction func showSetting(_ sender: Any) {
        // TODO: Settignページを作る
        let settingStoryBoard: UIStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingViewController: SettingViewController = settingStoryBoard.instantiateViewController(withIdentifier: "Setting") as! SettingViewController
        self.navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @IBAction func showLog(_ sender: Any) {
        let recordListStoryBoard: UIStoryboard = UIStoryboard(name: "RecordList", bundle: nil)
        let recordListViewController: RecordListViewController = recordListStoryBoard.instantiateViewController(withIdentifier: "RecordList") as! RecordListViewController
        self.navigationController?.pushViewController(recordListViewController, animated: true)
    }
    
    // MARK: - Record
    private func startRecording() throws {
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.audioEngine = AVAudioEngine()
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest.append(buffer)
        }
        try audioEngine.start()
        
        recognitionTask = speechRecognizer.recognitionTask(with: self.recognitionRequest) { (result, error) in
            if let result = result {
                print(result.bestTranscription.formattedString)
                self.inputText = result.bestTranscription.formattedString
                
                if self.inputText == "殺すぞ" {
                    self.vibrate()
                    self.isReadForReport = true
                }
            }
            
            if error != nil {
                print("fails with error: \(error!.localizedDescription)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            self.recognitionTask?.cancel()
            self.recognitionTask?.finish()
            self.audioEngine.stop()
            print("RESTART")
            if !self.isReadForReport || self.isRecording {
                try! self.startRecording()
            }
        })
    }
    
    func setVolumeView() {
        let volumeView = MPVolumeView(frame: CGRect(origin:CGPoint(x:/*-3000*/ 0, y:0), size:CGSize.zero))
        self.view.addSubview(volumeView)
        print("set volume view")
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.volumeChanged(notification:)), name:
        NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    func vibrate() {
        if let audioRecorder = self.audioRecorder {
            audioRecorder.pause()
            self.audioEngine.pause()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                audioRecorder.record()
            })
        }
        if self.audioEngine.isRunning {
            print("pause!")
            self.audioEngine.pause()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                do {
                    try self.audioEngine.start()
                } catch let error {
                  print("An error occurred starting audio engine. \(error.localizedDescription)")
                }
            })
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @objc func volumeChanged(notification: NSNotification) {
       
        if self.isReadForReport {
            if let userInfo = notification.userInfo {
                if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                    if volumeChangeType == "ExplicitVolumeChange" {
                        sendMail()
                        guard let audioRecorder = self.audioRecorder else { fatalError("レコーダが見つかりませんでした") }
                        audioRecorder.stop()
                        userDefaults.set(self.fileArray, forKey: "fileArray")
                        userDefaults.set(self.url, forKey: fileArray.last!)
                        self.recognitionTask?.cancel()
                        self.recognitionTask?.finish()
                        self.audioEngine.stop()
                        self.audioEngine.inputNode.removeTap(onBus: 0)
                        print("stop")
                        isRecording = false
                        
                        self.sendAudioFile(url: self.url!)
                        let alert = UIAlertController(title: nil, message: "通報しました", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        present(alert, animated: true, completion: nil)
                        self.isReadForReport = false
                    }
                }
            }
        }
    }
    
    func sendMail() {
        //メール送信が可能なら
        if MFMailComposeViewController.canSendMail() {
            let placeStr: String = "沖縄県南城市佐敷字新里1688"
//            if let location = self.userLocation {
//                let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
//                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//                    if let placemark = placemarks?.first {
//                        let administrativeArea = placemark.administrativeArea ?? ""
//                        let locality = placemark.locality ?? ""
//                        let thoroughfare = placemark.thoroughfare ?? ""
//                        let subThoroughfare = placemark.subThoroughfare ?? ""
//                        placeStr = administrativeArea + locality + thoroughfare + subThoroughfare
//                        print(placeStr)
//                    }
//                }
//            }
            let f = DateFormatter()
               f.timeStyle = .full
               f.dateStyle = .full
               f.locale = Locale(identifier: "ja_JP")
               let now = Date()
               print(f.string(from: now))
               //MFMailComposeVCのインスタンス
               let mail = MFMailComposeViewController()
               //MFMailComposeのデリゲート
               mail.mailComposeDelegate = self
               //送り先
            mail.setToRecipients(["syankenpon@gmail.com"])

               mail.setSubject("揉め事です")
               //メッセージ本"
               mail.setMessageBody("<p>1.発生場所</p><p>\(placeStr)</p><p>2.発生時間</p><p>\(f.string(from: now))</p><p>3.被害状況</p><p>揉め事です</p><p>4.あなたの住所・氏名・現在地</p><p>福岡県中央区●●●</p>", isHTML: true)
               //メールを表示
               self.present(mail, animated: true, completion: nil)
        //メール送信が不可能なら
        } else {
            //アラートで通知
            let alert = UIAlertController(title: "No Mail Accounts", message: "Please set up mail accounts", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
        //エラー処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            //送信失敗
            print(error ?? "")
        } else {
            switch result {
            case .cancelled: break
                //キャンセル
            case .saved: break
                //下書き保存
            case .sent: break
                //送信
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
    func sendAudioFile(url: URL) {
        print(url)
        guard let location = self.userLocation else { return }
        let req = SendAudioFile(lat: location.latitude, lng: location.longitude, audioFileUrl: url)
        Session.send(req) { result in
            switch result {
                case .success(let res):
                    print(res)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let f = DateFormatter()
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        f.locale = Locale(identifier: "ja_JP")
        let now = f.string(from: Date()) + ".flac"
        self.url = docsDirect.appendingPathComponent(now)
        guard let url = self.url else { fatalError("urlが取得できませんでした") }
        self.fileArray.append(now)
        self.urlArray.append(url)
        return url
    }
    
    // MARK: - UI Setting
    func setUI() {
        setVolumeView()
        recordButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
        settingButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
        recordListButton.frame.size = CGSize(width: self.view.bounds.maxX/3, height: self.view.bounds.maxY/15)
        whiteView.frame = CGRect(x:0,y:4*self.view.bounds.maxY/5,width:self.view.bounds.maxX,height:self.view.bounds.maxY/5)
        recordButton.layer.position = CGPoint(x: self.view.bounds.midX, y:self.view.bounds.maxY/100)
        settingButton.layer.position = CGPoint(x: self.view.bounds.midX/2, y:self.view.bounds.maxY/10)
        recordListButton.layer.position = CGPoint(x: 3*self.view.bounds.midX/2, y:self.view.bounds.maxY/10)
    }
}
