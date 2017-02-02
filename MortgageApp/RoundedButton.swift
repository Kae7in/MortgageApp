//
//  RoundedButton.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/27/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit

class RoundedButton:UIButton {
   override func awakeFromNib() {
        
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.height / 2.0
        layer.masksToBounds = true
        setTitleColor(UIColor.white, for: UIControlState.normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        removeHighlight()
    }
    
    func enable(enabled: Bool) {
        self.isEnabled = enabled
        backgroundColor = enabled ? UIColor.primaryButton() : UIColor.secondary()
    }
    
    func highlight() {
        backgroundColor = UIColor.primaryButtonHiglight()
    }
    
    func removeHighlight() {
        backgroundColor = UIColor.primaryButton()
    }
}
