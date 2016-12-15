//
//  View4.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View4: IntroDetailVC {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var interestSavedLabel: UILabel!
    @IBOutlet weak var timeSavedLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    var displayed: Bool = false
    var interestSaved: NSDecimalNumber? = nil
    var timeSaved: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        calculateInterestAndTimeSaved()
    }
    
    func calculateInterestAndTimeSaved() {
        // Calculate interest saved and time saved with one extra payment
        let oldInterest = mortgage!.totalLoanCost
        let oldNumPayments = mortgage!.numberOfPayments
        let mc = MortgageCalculator()
        mortgage!.extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(mortgage!.monthlyPayment)]]
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
        let newInterest = mortgage!.totalLoanCost
        let newNumPayments = mortgage!.numberOfPayments
        interestSaved = oldInterest.subtracting(newInterest)
        timeSaved = oldNumPayments - newNumPayments
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !displayed {
            displayed = true
            displayMortgageData()
        }
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "less"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "sooner"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        animate(label: interestSavedLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved!, increment: 10, interval: 0.001)
        animate(label: timeSavedLabel, startValue: NSDecimalNumber(value: 0.0), endValue: NSDecimalNumber(value: timeSaved!), increment: 1, interval: 0.5, dollars: false)
        
        /* Format the tagline */
        let attributedString = NSMutableAttributedString()
        
        // Append everything before the $
        var comps:[String] = taglineLabel.text!.components(separatedBy: "$")
        attributedString.append(NSAttributedString(string: comps[0]))
        
        // Append the bolded dollar amount
        let string = "$" + String(mortgage!.monthlyPayment.dividing(by: NSDecimalNumber(value: 12.0)).int32Value)
        let boldDollars = NSMutableAttributedString(string: string)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 22.0)!]
        boldDollars.addAttributes(boldFontAttribute, range: (string as NSString).range(of: string))
        attributedString.append(boldDollars)
        
        // Append everything after the $
        attributedString.append(NSAttributedString(string: comps[1]))
        
        taglineLabel.attributedText = attributedString
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
