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
        
//        interestSavedLabel.text! = numberFormatter.string(from: interestSaved)!.components(separatedBy: ".")[0]
//        newInterestLabel.text! = interestSavedLabel.text!
        
//        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
//            interestSavedCounter = self.animate(label: self.interestSavedLabel, value: self.interestSaved!, timer: timer, counter: interestSavedCounter, increment: 10)
//        }
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
//            timeSavedCounter = self.animate(label: self.timeSavedLabel, value: NSDecimalNumber(value: self.timeSaved!), timer: timer, counter: timeSavedCounter, increment: 1)
//        }
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
