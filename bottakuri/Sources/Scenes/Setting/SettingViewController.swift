//
//  SettingViewController.swift
//  bottakuri
//
//  Created by 吉川莉央 on 2020/01/12.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var reportDesticationLabel: UILabel!
    

    override func numberOfSections(in tableView: UITableView) -> Int {
      return 2
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // それぞれのセクション毎に何行のセルがあるかを返します
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

        // Do any additional setup after loading the view.
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
