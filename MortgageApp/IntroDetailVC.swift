//
//  IntroDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class IntroDetailVC: UIViewController {

    var horizontalLine: UIView? = nil
    var label: UILabel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackgroundColors()
        drawHorizontalLine()
    }
    
    func setBackgroundColors() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.init(rgbColorCodeRed: 39, green: 227, blue: 233, alpha: 1).cgColor, UIColor.init(rgbColorCodeRed: 0, green: 148, blue: 180, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
        //use startPoint and endPoint to change direction of gradient (http://stackoverflow.com/a/20387923/2057171)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func drawHorizontalLine() {
        let lineFrame = CGRect(x: 0.0, y: (view.frame.height / 2.0) - 35.0, width: view.frame.width, height: 1.0)
        horizontalLine = UIView(frame: lineFrame)
        horizontalLine?.backgroundColor = UIColor.white
        view.addSubview(horizontalLine!)
    }
    
    func addMessage(message: Int) {
        switch message {
        case 1:
            let string = "Your loan is made up of principal and interest, which combine to form the remaining balance."
            let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
            let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
            let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
            
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "balance"))
            
            view.addSubview(generateLabelWith(attributedString: attributedString, message: message))
            break
        default:
            break
        }
    }
    
    func generateLabelWith(attributedString: NSMutableAttributedString, message: Int) -> UILabel {
        label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: view.frame.width - 20.0, height: CGFloat.greatestFiniteMagnitude))  // maximum height used because we will resize dynamically
        label?.textAlignment = .left
        label?.attributedText = attributedString
        switch message {
        case 1:
            label?.numberOfLines = 4
        default:
            break
        }
        label?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label!.adjustsFontSizeToFitWidth = true
        label!.minimumScaleFactor = 24.0 / label!.font.pointSize  // Dynamically resize font to fit label
        label?.sizeToFit()  // Must dynamically size resize label to fit the text more exactly
        let y: CGFloat = self.horizontalLine!.frame.minY - label!.frame.height
        label!.frame = CGRect(x: label!.frame.minX, y: y - 5.0, width: label!.frame.width, height: label!.frame.height)
        
        return label!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
