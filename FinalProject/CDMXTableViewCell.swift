//
//  CDMXTableViewCell.swift
//  FinalProject
//
//  Created by Roger A. Chiroque on 3/30/17.
//  Copyright © 2017 Roger Chiroque. All rights reserved.
//

import UIKit

class CDMXTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
