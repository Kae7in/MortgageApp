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
        setBackgroundColors()
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
