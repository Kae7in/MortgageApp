//
//  MortgageDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class MortgageDetailVC: UIViewController {
    
    var m: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceCents: UILabel!
    @IBOutlet weak var yearsLeftLabel: UILabel!
    @IBOutlet weak var monthsLeftLabel: UILabel!
    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        m = mc.calculateMortgage(mortgage: m!)
        updateLabels()
    }
    
    func updateLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let balanceComponents = numberFormatter.string(from: m!.loanAmount().adding(m!.totalLoanCost))!.components(separatedBy: ".")
        
        balance.text! = balanceComponents[0]
        balanceCents.text! = "." + balanceComponents[1]
        
        let yearsLeft = self.m!.numberOfPayments / 12
        let remainingMonthsLeft = self.m!.numberOfPayments % 12
        let monthlyPayment = numberFormatter.string(from: self.m!.monthlyPayment)
        
        self.yearsLeftLabel.text! = String(yearsLeft) + "yr"
        self.monthsLeftLabel.text! = String(remainingMonthsLeft) + "mo"
        self.monthlyPaymentLabel.text! = "$" + monthlyPayment!
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
