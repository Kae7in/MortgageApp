//
//  UIColor+themes.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/25/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

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
    
    static func customGrey(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 247, green: 247, blue: 247, alpha: 1.0)
    }
    
    static func textGrey(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1.0)
    }

    static func lineGrey(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 151, green: 151, blue: 151, alpha: 1.0)
    }

    static func primaryButton(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 227, green: 71, blue: 52, alpha: 1.0)
    }
    
    static func primaryButtonHiglight(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 177, green: 21, blue: 2, alpha: 1.0)
    }
}
