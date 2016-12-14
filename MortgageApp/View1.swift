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
    
    // Number animation stuff
    var principalCounter: NSDecimalNumber = 0.0
    var interestCounter: NSDecimalNumber = 0.0
    var balanceCounter: NSDecimalNumber = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mc = MortgageCalculator()
        mortgage = mc.calculateMortgage(mortgage: mortgage!)
        
        
        formatMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayMortgageData()
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
            
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "balance"))

        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.loanAmount()
            self.principalCounter = self.animate(label: self.principalLabel, value: value, timer: timer, counter: self.principalCounter, increment: 1000)
        }
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.totalLoanCost
            self.interestCounter = self.animate(label: self.interestLabel, value: value, timer: timer, counter: self.interestCounter, increment: 1000)
        }
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.loanAmount().adding(self.mortgage!.totalLoanCost)
            self.balanceCounter = self.animate(label: self.balanceLabel, value: value, timer: timer, counter: self.balanceCounter, increment: 1000)
        }
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
