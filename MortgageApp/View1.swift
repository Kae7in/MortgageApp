//
//  View1.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View1: IntroDetailVC {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var principalLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mc = MortgageCalculator()
        self.mortgage = mc.calculateMortgage(mortgage: mortgage!)
        formatMessage()
        displayMortgageData()
    }
    
    
    @IBAction func nextIntroVC(_ sender: UIButton) {
        if let secondViewController = pageController?.orderedViewControllers[1] {
            pageController!.setViewControllers([secondViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 38.0)!, NSForegroundColorAttributeName: UIColor.black]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!, NSForegroundColorAttributeName: UIColor.init(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1)]
            
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "balance"))

        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    
    func displayMortgageData() {
        var value: NSDecimalNumber = self.mortgage!.loanAmount()
        animate(label: principalLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, interval: 0.001)
        value = self.mortgage!.totalLoanCost
        animate(label: interestLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, interval: 0.001)
        value = self.mortgage!.loanAmount().adding(self.mortgage!.totalLoanCost)
        animate(label: balanceLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, interval: 0.001)
    }
    
    
    // TODO: Produce all the necessary mortgage data

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
