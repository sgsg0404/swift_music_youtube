//
//  TableViewCell.swift
//  CVI
//
//  Created by AppsLab on 2/22/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import UIKit
import ESTMusicIndicator

class TableViewCell2: UITableViewCell {
    // MARK: Properties
    
    var indicator:ESTMusicIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}