//
//  IntroDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/14/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class IntroDetailVC: UIViewController {
    
    var mortgage: Mortgage? = nil
    var pageController: IntroPVC? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        setBackgroundColors()
        self.view.backgroundColor = UIColor.white
        
        self.addTitleLabel()
    }
    
    func addTitleLabel() {
        let label = UILabel(frame: CGRect.zero)
        
        let string = "Making Extra Payments"
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor.init(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1)]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        label.attributedText = attributedString
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute , multiplier: 1.0, constant: 250)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        let xConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.15, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }
    
    func animate(label: UILabel, startValue: NSDecimalNumber, endValue: NSDecimalNumber, interval: TimeInterval, dollars: Bool = true) {
        var counter = startValue
        var increment = endValue.subtracting(startValue).int32Value
        if increment > 300 {
            increment = increment / 150
        } else if increment < -300 {
            increment = increment / 150
        } else if increment > 0 {
            increment = 1
        } else if increment < 0 {
            increment = -1
        }
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            
            var str = dollars ? "$" + numberFormatter.string(from: counter)! : numberFormatter.string(from:counter)!
            label.attributedText! = NSAttributedString(string: str)
            
            if increment > 0 {
                if counter.compare(endValue) == ComparisonResult.orderedDescending ||
                    counter.compare(endValue) == ComparisonResult.orderedSame {
                    timer.invalidate()
                    str = dollars ? "$" + numberFormatter.string(from: endValue)! : numberFormatter.string(from:endValue)!
                    label.attributedText! = NSAttributedString(string: str.components(separatedBy: ".")[0])
                }
            } else if increment < 0 {
                if counter.compare(endValue) == ComparisonResult.orderedAscending ||
                    counter.compare(endValue) == ComparisonResult.orderedSame {
                    timer.invalidate()
                    str = dollars ? "$" + numberFormatter.string(from: endValue)! : numberFormatter.string(from:endValue)!
                    label.attributedText! = NSAttributedString(string: str.components(separatedBy: ".")[0])
                }
            } else {
                return
            }
            
            counter = counter.adding(NSDecimalNumber(value: increment))
        }
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
