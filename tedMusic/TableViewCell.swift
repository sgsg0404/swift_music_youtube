//
//  TableViewCell.swift
//  CVI
//
//  Created by AppsLab on 2/22/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import UIKit
import ESTMusicIndicator

class TableViewCell: UITableViewCell {
    // MARK: Properties
    
        var indicator:ESTMusicIndicatorView!

    @IBOutlet weak var indic: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indicator = ESTMusicIndicatorView.init()
        indicator.tintColor = UIColor.whiteColor()
        indicator.backgroundColor = UIColor.clearColor()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}