//
//  RecordListViewController.swift
//  bottakuri
//
//  Created by ymgn on 2019/11/17.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import AVFoundation

class RecordListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    var dataList: [Record] = []
    var isPlaying = false
    var audioPlayer: AVAudioPlayer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let recordNib = UINib(nibName: "RecordListCell", bundle: nil)
        tableView.register(recordNib, forCellReuseIdentifier: "RecordListCell")
        guard let audioFiles = self.userDefaults.array(forKey: "fileArray") else { return }
        for file in audioFiles {
            let url = userDefaults.url(forKey: file as! String)
            let record = Record(name: file as! String, url: url!)
            dataList.append(record)
            }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = dataList[indexPath.row]
        let cell: RecordListCell = tableView.dequeueReusableCell(withIdentifier: "RecordListCell", for: indexPath) as! RecordListCell
        cell.fileName.text = record.name
        cell.url = record.url
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isPlaying {
            self.audioPlayer = try! AVAudioPlayer(contentsOf: dataList[indexPath.row].url)
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
            
            isPlaying = true
        } else {
            self.audioPlayer.stop()
            isPlaying = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            audioPlayer.stop()
            isPlaying = false
        }
    }
}
