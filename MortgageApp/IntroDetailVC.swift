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
    
    func animate(label: UILabel, value: NSDecimalNumber, timer: Timer, counter: NSDecimalNumber, increment: Int) -> NSDecimalNumber {
        label.attributedText! = NSAttributedString(string: "$" + counter.stringValue)
        
        if increment > 0 {
            if counter.compare(value) == ComparisonResult.orderedDescending ||
                counter.compare(value) == ComparisonResult.orderedSame {
                timer.invalidate()
                label.attributedText! = NSAttributedString(string: "$" + value.stringValue.components(separatedBy: ".")[0])
            }
        } else if increment < 0 {
            if counter.compare(value) == ComparisonResult.orderedAscending ||
                counter.compare(value) == ComparisonResult.orderedSame {
                timer.invalidate()
                label.attributedText! = NSAttributedString(string: "$" + value.stringValue.components(separatedBy: ".")[0])
            }
        } else {
            return counter
        }
        
        return counter.adding(NSDecimalNumber(value: increment))
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
