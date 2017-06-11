//
//  TableViewCell.swift
//  FinalProject
//
//  Created by Roger A. Chiroque on 3/20/17.
//  Copyright © 2017 Roger Chiroque. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
