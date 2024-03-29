//
//  View6.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View6: IntroDetailVC {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var interestedSaved7YearsLabel: UILabel!
    @IBOutlet weak var cdReturns7YearsLabel: UILabel!
    @IBOutlet weak var interestSaved30YearsLabel: UILabel!
    @IBOutlet weak var cdReturns30YearsLabel: UILabel!
    var displayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        createExtraPayment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !displayed {
            displayed = true
            displayMortgageData()
        }
    }
    
    func createExtraPayment() {
        // Calculate interest saved and time saved with one extra payment
        let mc = MortgageCalculator()
        
        mortgage!.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":12, "extraAmount":Int(mortgage!.monthlyPayment)]]
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
    }
    
    @IBAction func nextIntroVC(_ sender: UIButton) {
        if let secondViewController = pageController?.orderedViewControllers[6] {
            pageController!.setViewControllers([secondViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 38.0)!, NSForegroundColorAttributeName: UIColor.black]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!, NSForegroundColorAttributeName: UIColor.init(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1)]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "7x more"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        // Interest saved from extra mortgage payments
        let interestSaved7Years = self.mortgage!.interestSavedForRange(start: 0, end: 7*12)
        let interestSaved30Years = self.mortgage!.totalInterestSavings()
        animate(label: interestedSaved7YearsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved7Years, interval: 0.001)
        animate(label: interestSaved30YearsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved30Years, interval: 0.001)
        
        // Interest returns from average-rate CD
        let cdReturns7Years = calculateCompoundInterest(investment: self.mortgage!.monthlyPayment, yearsToContribute: 7)
        let cdReturns30Years = calculateCompoundInterest(investment: self.mortgage!.monthlyPayment, yearsToContribute: mortgage!.originalMortgage!.loanTermMonths / 12)
        self.cdReturns7YearsLabel.text! = "$" + numberFormatter.string(from: cdReturns7Years)!.components(separatedBy: ".").first!
        self.cdReturns30YearsLabel.text! = "$" + numberFormatter.string(from: cdReturns30Years)!.components(separatedBy: ".").first!
    }
    
    func calculateCompoundInterest(investment: NSDecimalNumber, yearsToContribute: Int) -> NSDecimalNumber {
        let yearlyRate = getAverageCDRate().dividing(by: NSDecimalNumber(value: 100.0))
        var futureValue = NSDecimalNumber(value: 0.0)
        var contributed = NSDecimalNumber(value: 0.0)
        for _ in 1...yearsToContribute {
            futureValue = futureValue.adding(investment).multiplying(by: NSDecimalNumber(value: 1.0).adding(yearlyRate))
            contributed = contributed.adding(investment)
        }
        return futureValue.subtracting(contributed)
    }
    
    func getAverageCDRate() -> NSDecimalNumber {
        // TODO: Find API that serves industry average rate
        return NSDecimalNumber(value: 0.51)
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
