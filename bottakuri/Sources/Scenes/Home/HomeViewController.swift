//
//  HomeViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Speech

class HomeViewController: UIViewController, AVAudioRecorderDelegate {
    
    var isRecording: Bool = false
    var audioRecorder: AVAudioRecorder?
    var fileArray: [String] = []
    var urlArray: [URL] = []
    var url: URL?
    let userDefaults = UserDefaults.standard
    var isReadForReport: Bool = false

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var recordButton: circleButton!
    
    @IBOutlet weak var emergencyButton: UIButton! {
        didSet {
            emergencyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var audioEngine = AVAudioEngine()
    private var inputText: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        let volumeView = MPVolumeView(frame: CGRect(origin:CGPoint(x:/*-3000*/ 0, y:0), size:CGSize.zero))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.volumeChanged(notification:)), name:
        NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        guard let fileArray = self.userDefaults.array(forKey: "fileArray") else { return }
        for file in fileArray {
            let url = self.userDefaults.url(forKey: file as! String)
            self.urlArray.append(url!)
        }
    }
    
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
                    let alert = UIAlertController(title: nil, message: "通報の準備が整いました", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
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
    
    @objc func volumeChanged(notification: NSNotification) {
        if self.isReadForReport {
            if let userInfo = notification.userInfo {
                if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                    if volumeChangeType == "ExplicitVolumeChange" {
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
    
    @IBAction func emergency(_ sender: Any) {
        let emergencyStoryBoard: UIStoryboard = UIStoryboard(name: "Emergency", bundle: nil)
        let emergencyViewContorller: EmergencyViewController = emergencyStoryBoard.instantiateViewController(withIdentifier: "Emergency") as! EmergencyViewController
        self.navigationController?.pushViewController(emergencyViewContorller, animated: true)
    }
    @IBAction func showRecordList(_ sender: Any) {
        let recordListStoryBoard: UIStoryboard = UIStoryboard(name: "RecordList", bundle: nil)
        let recordListViewController: RecordListViewController = recordListStoryBoard.instantiateViewController(withIdentifier: "RecordList") as! RecordListViewController
        self.navigationController?.pushViewController(recordListViewController, animated: true)
    }
    
    @IBAction func record(_ sender: Any) {
        if isRecording {
            toCircle()
            guard let audioRecorder = self.audioRecorder else { fatalError("レコーダが見つかりませんでした") }
            audioRecorder.stop()
            userDefaults.set(self.fileArray, forKey: "fileArray")
            userDefaults.set(self.url, forKey: fileArray.last!)
            self.recognitionTask?.cancel()
            self.recognitionTask?.finish()
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            isRecording = false
        } else {
            toSquare()
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
               AVFormatIDKey: Int(kAudioFormatLinearPCM),
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
            isRecording = true
        }
    }
    
    func getURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let f = DateFormatter()
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        f.locale = Locale(identifier: "ja_JP")
        let now = f.string(from: Date())
        self.url = docsDirect.appendingPathComponent(now)
        guard let url = self.url else { fatalError("urlが取得できませんでした") }
        self.fileArray.append(now)
        self.urlArray.append(url)
        return url
    }
    
    func toCircle() {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.duration = 0.1
        animation.fromValue = 0.0
        animation.toValue = self.recordButton.bounds.size.width / 2.0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.recordButton.layer.add(animation, forKey: nil)
    }
    
    func toSquare() {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.duration = 0.1
        animation.fromValue = 0.0
        animation.toValue = 0.0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.recordButton.layer.add(animation, forKey: nil)
    }
}

class circleButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }
}
