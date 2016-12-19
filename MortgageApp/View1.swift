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
        // Do any additional setup after loading the view.
        let mc = MortgageCalculator()
        mortgage = mc.calculateMortgage(mortgage: mortgage!)
        
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
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Thin", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
            
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "balance"))

        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        var value: NSDecimalNumber = self.mortgage!.loanAmount()
        animate(label: principalLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, increment: 1000, interval: 0.001)
        value = self.mortgage!.totalLoanCost
        animate(label: interestLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, increment: 1000, interval: 0.001)
        value = self.mortgage!.loanAmount().adding(self.mortgage!.totalLoanCost)
        animate(label: balanceLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, increment: 1000, interval: 0.001)
    }
    
    
    
    
    // TODO: Produce all the necessary mortgage data

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
