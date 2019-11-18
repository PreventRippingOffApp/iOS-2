//
//  HomeViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/09/19.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, AVAudioRecorderDelegate {
    
    var isRecording: Bool = false
    var audioRecorder: AVAudioRecorder?
    var fileArray: [String] = []
    var urlArray: [URL] = []
    var url: URL?
    let userDefaults = UserDefaults.standard

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        userDefaults.set([], forKey: "fileArray")
        
        self.fileArray = self.userDefaults.array(forKey: "fileArray") as! [String]
        for file in fileArray {
            let url = self.userDefaults.url(forKey: file)
            self.urlArray.append(url!)
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
