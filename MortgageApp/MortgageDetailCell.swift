//
//  MortgageDetailCell.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/7/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import UIKit

class MortgageDetailCell: UITableViewCell {
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add cell separators since we removed them in the table view
        var image = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1.0))
        image.backgroundColor = UIColor.cellSeparator()
        contentView.addSubview(image)
        image = UIImageView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1.0))
        image.backgroundColor = UIColor.cellSeparator()
        contentView.addSubview(image)

    }
}
