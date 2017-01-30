//
//  RegisterInformationVC.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/30/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit


class RegisterInformationVC: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var facebookRegisterLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        // Construct facebook registration attributes
        let string = NSLocalizedString("Register with Facebook", comment: "Prompt for user to register with Faceobok")
        let attributeString = NSMutableAttributedString(string: string, attributes:
            [
                NSForegroundColorAttributeName : UIColor.textGrey(),
                NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
            ]
        )
        
        let range = NSRange(location: 14, length: 8)
        attributeString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        attributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
        facebookRegisterLabel.attributedText = attributeString
        
        super.viewDidLoad()
    }
    
}
