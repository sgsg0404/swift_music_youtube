//
//  TableViewCell.swift
//  CVI
//
//  Created by AppsLab on 2/22/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    // MARK: Properties
    
    

    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}