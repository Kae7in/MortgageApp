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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        let mc = MortgageCalculator()
        mortgage!.extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(mortgage!.monthlyPayment)]]
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !displayed {
            displayed = true
            displayMortgageData()
            
            // TODO: GET RID OF THIS
            // Revert mortgage back to original state -- without extra payments
            let mc = MortgageCalculator()
            mortgage!.extras = []
            mortgage = mc.calculateMortgage(mortgage: mortgage!)
        }
    }
    
    @IBAction func nextIntroVC(_ sender: UIButton) {
        if let secondViewController = pageController?.orderedViewControllers[3] {
            pageController!.setViewControllers([secondViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 38.0)!, NSForegroundColorAttributeName: UIColor.black]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!, NSForegroundColorAttributeName: UIColor.init(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1)]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let oldInterest = self.mortgage!.originalMortgage!.totalLoanCost
        interestLabel.text! = "$" + numberFormatter.string(from: oldInterest)!.components(separatedBy: ".")[0]
        newInterestLabel.text! = interestLabel.text!
        
        var value = oldInterest.subtracting(self.mortgage!.totalLoanCost)
        animate(label: interestSavedLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, interval: 0.001)
        value = self.mortgage!.totalLoanCost
        animate(label: newInterestLabel, startValue: oldInterest, endValue: value, interval: 0.001)
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
