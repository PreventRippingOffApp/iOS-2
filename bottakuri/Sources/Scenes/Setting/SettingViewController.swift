//
//  SettingViewController.swift
//  bottakuri
//
//  Created by 吉川莉央 on 2020/01/12.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    

    override func numberOfSections(in tableView: UITableView) -> Int {
      return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

      switch section {
      case 0: // 一般
        return 1
      case 1: // アプリについて
        return 2
      default:
        return 0
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange),
        name: UserDefaults.didChangeNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
      if let name = UserDefaults.standard.value(forKey: "name") as? String {
        nameLabel.text = name
      }
    }

    deinit {
      NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
