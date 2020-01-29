//
//  SettingReportTableViewController.swift
//  bottakuri
//
//  Created by 吉川莉央 on 2020/01/25.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit

class SettingReportTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
          nameTextField.text = name
        }
        if let phoneNumber = UserDefaults.standard.value(forKey: "phoneNumber") as? String {
          phoneNumberTextField.text = phoneNumber
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      // keyboardを隠す
        textField.resignFirstResponder()
        UserDefaults.standard.set(nameTextField.text, forKey: "name")
        UserDefaults.standard.set(phoneNumberTextField.text, forKey: "phoneNumber")

      return true
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
