//
//  BorderedInputView.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/30/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit

class BorderedInputView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add border to bottom of view
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.height-1, width: self.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.lineGrey().cgColor
        self.layer.addSublayer(bottomBorder)
    }
}
