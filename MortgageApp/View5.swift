//
//  View5.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View5: IntroDetailVC {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var interestSavedLabel: UILabel!
    @IBOutlet weak var timeSavedYearsLabel: UILabel!
    @IBOutlet weak var timeSavedMonthsLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    var displayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        createExtraPayment()
    }
    
    func createExtraPayment() {
        // Calculate interest saved and time saved with one extra payment
        let mc = MortgageCalculator()
        
        mortgage!.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":12, "extraAmount":Int(mortgage!.monthlyPayment)]]
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !displayed {
            displayed = true
            displayMortgageData()
        }
    }
    
    @IBAction func nextIntroVC(_ sender: UIButton) {
        if let secondViewController = pageController?.orderedViewControllers[5] {
            pageController!.setViewControllers([secondViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "every year"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let interestSaved = self.mortgage!.totalInterestSavings()
        animate(label: interestSavedLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved, increment: 100, interval: 0.001)
        let yearsSaved = self.mortgage!.monthsSaved() / 12
        let remainingMonthsSaved = self.mortgage!.monthsSaved() % 12
        animate(label: timeSavedYearsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: NSDecimalNumber(value: yearsSaved), increment: 1, interval: 0.1, dollars: false)
        animate(label: timeSavedMonthsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: NSDecimalNumber(value: remainingMonthsSaved), increment: 1, interval: 0.1, dollars: false)
        
        /* Format the tagline */
        let attributedString = NSMutableAttributedString()
        
        // Append everything before the %
        var comps:[String] = taglineLabel.text!.components(separatedBy: "%")
        attributedString.append(NSAttributedString(string: comps[0]))
        
        // Append the bolded dollar amount
        let string = String(describing: mortgage!.interestRate.decimalValue) + "%"
        let boldPercent = NSMutableAttributedString(string: string)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 22.0)!]
        boldPercent.addAttributes(boldFontAttribute, range: (string as NSString).range(of: string))
        attributedString.append(boldPercent)
        
        // Append everything after the %
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
