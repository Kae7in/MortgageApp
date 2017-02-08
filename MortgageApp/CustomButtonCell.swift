//
//  CustomButtonCell.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/2/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import UIKit

class CustomButtonCell: UITableViewCell {
    
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var tappedAction: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func addTarget(_ target: @escaping () -> Void) {
        tappedAction = target
        
        if tappedAction != nil {
            customButton.addTarget(self, action: #selector(onTouchUpInside), for: UIControlEvents.touchUpInside)
        }
    }
    
    @IBAction func onTouchDown(_ sender: Any) {
        // TODO: Add tint on touchDown event
    }
    
    @IBAction func onTouchUpInside(_ sender: Any) {
        if tappedAction != nil {
            tappedAction!()
        }
    }
}
