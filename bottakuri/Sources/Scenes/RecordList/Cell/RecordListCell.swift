//
//  RecordListCell.swift
//  bottakuri
//
//  Created by ymgn on 2019/11/17.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit

class RecordListCell: UITableViewCell {
    @IBOutlet weak var fileName: UILabel!
    
    var url: URL!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
