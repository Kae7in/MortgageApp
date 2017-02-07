//
//  MortgageTypeCell.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/7/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import UIKit

class MortgageTypeCell: UITableViewCell {
    @IBOutlet weak var mortgageTypeSegment: UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
}
