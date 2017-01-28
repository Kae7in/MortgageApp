//
//  RoundedButton.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/27/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//
// Borrowed from http://stackoverflow.com/questions/26961274/how-can-i-make-a-button-have-a-rounded-border-in-swift

import UIKit

@IBDesignable
class RoundedButton:UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    //Normal state bg and border
    @IBInspectable var normalBorderColor: UIColor? {
        didSet {
            layer.borderColor = normalBorderColor?.cgColor
        }
    }
    
    @IBInspectable var normalBackgroundColor: UIColor? {
        didSet {
            setBgColorForState(color: normalBackgroundColor, forState: .normal)
        }
    }
    
    
    //Highlighted state bg and border
    @IBInspectable var highlightedBorderColor: UIColor?
    
    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            setBgColorForState(color: highlightedBackgroundColor, forState: .highlighted)
        }
    }
    
    
    private func setBgColorForState(color: UIColor?, forState: UIControlState){
        if color != nil {
            setBackgroundImage(UIImage.imageWithColor(color: color!), for: forState)
            
        } else {
            setBackgroundImage(nil, for: forState)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layer.frame.height / 2
        clipsToBounds = true
        
        if borderWidth > 0 {

            // TODO: CGColorEqualToColor is not available in Swift
            // Try this...
//            var red1:CGFloat=0, green1:CGFloat=0, blue1:CGFloat=0, alpha1:CGFloat=0
//            colour1.getRed(&red1, green:&green1, blue:&blue1, alpha:&alpha1)
//            
//            var red2:CGFloat=0, green2:CGFloat=0, blue2:CGFloat=0, alpha2:CGFloat=0
//            colour2.getRed(&red2, green:&green2, blue:&blue2, alpha:&alpha2)
//            
//            XCTAssertEqual(red1, red2)
//            XCTAssertEqual(green1, green2)
//            XCTAssertEqual(blue1, blue2)
//            XCTAssertEqual(alpha1, alpha2)
            
//            if state == .normal && !CGColorEqualToColor(layer.borderColor, normalBorderColor?.cgColor) {
//                layer.borderColor = normalBorderColor?.cgColor
//            } else if state == .highlighted && highlightedBorderColor != nil{
//                layer.borderColor = highlightedBorderColor!.cgColor
//            }
        }
    }
    
}

//Extension Required by RoundedButton to create UIImage from UIColor
extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
