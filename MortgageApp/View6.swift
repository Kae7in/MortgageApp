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
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "7x more"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let interestSaved7Years = self.mortgage!.interestSavedForRange(start: 0, end: 7*12)
        let interestSaved30Years = self.mortgage!.totalInterestSavings()
        animate(label: interestedSaved7YearsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved7Years, increment: 3, interval: 0.001)
        animate(label: interestSaved30YearsLabel, startValue: NSDecimalNumber(value: 0.0), endValue: interestSaved30Years, increment: 100, interval: 0.001)
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
