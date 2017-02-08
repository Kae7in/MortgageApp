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
    
    var valueChangedAction: ((Int) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    func addTarget(_ target: @escaping (Int) -> Void) {
        valueChangedAction = target
        
        if valueChangedAction != nil {
            mortgageTypeSegment.addTarget(self, action: #selector(onValueChanged), for: UIControlEvents.valueChanged)
        }
    }
    
    func onValueChanged(segment: UISegmentedControl) {
        if valueChangedAction != nil {
            valueChangedAction!(segment.selectedSegmentIndex)
        }
    }
}
