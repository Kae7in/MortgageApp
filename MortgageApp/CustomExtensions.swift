//
//  CustomExtensions.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/17/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import Foundation
import UIKit



extension UIColor {
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
        
    }
    
    static func primary(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 227, green: 71, blue: 52, alpha: alpha)
    }
    
    static func secondary(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 74, green: 74, blue: 74, alpha: alpha)
    }
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
