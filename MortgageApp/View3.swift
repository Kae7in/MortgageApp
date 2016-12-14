//
//  View3.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View3: IntroDetailVC {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var interestSavedLabel: UILabel!
    @IBOutlet weak var newInterestLabel: UILabel!
    var displayed: Bool = false
    
    // Number animation stuff
    var interestSavedCounter: NSDecimalNumber = 0.0
    var oldInterest: NSDecimalNumber = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        oldInterest = mortgage!.totalLoanCost
        let mc = MortgageCalculator()
        mortgage!.extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(mortgage!.monthlyPayment)]]
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !displayed {
            displayed = true
            displayMortgageData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        interestLabel.text! = numberFormatter.string(from: oldInterest)!.components(separatedBy: ".")[0]
        newInterestLabel.text! = interestLabel.text!
        
        let diff: NSDecimalNumber = self.oldInterest.subtracting(self.mortgage!.totalLoanCost)
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            self.interestSavedCounter = self.animate(label: self.interestSavedLabel, value: diff, timer: timer, counter: self.interestSavedCounter, increment: 8)
        }
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.totalLoanCost
            self.oldInterest = self.animate(label: self.newInterestLabel, value: value, timer: timer, counter: self.oldInterest, increment: -8)
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
