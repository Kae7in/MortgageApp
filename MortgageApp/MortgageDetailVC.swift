//
//  MortgageDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class MortgageDetailVC: UIViewController {
    
    
    var mortgage: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceCents: UILabel!
    @IBOutlet weak var yearsLeftLabel: UILabel!
    @IBOutlet weak var monthsLeftLabel: UILabel!
    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mortgage = mc.calculateMortgage(mortgage: mortgage!)
        layoutViews()
    }
    
    
    func layoutViews() {
        // TODO: Use current balance remaining and current time left
        updateLabels(balanceLeft: mortgage!.loanAmount().adding(mortgage!.totalLoanCost), timeLeft: self.mortgage!.numberOfPayments)
        layoutNavigationBar()
        layoutChart()
    }
    
    
    func updateLabels(balanceLeft: NSNumber, timeLeft: Int) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let balanceComponents = numberFormatter.string(from: balanceLeft)!.components(separatedBy: ".")
        
        balance.text! = balanceComponents.first!
        if balanceComponents.count > 1 {
            balanceCents.text! = "." + balanceComponents.last!
        } else {
            balanceCents.text! = ".00"
        }
        
        let yearsLeft = timeLeft / 12
        let remainingMonthsLeft = timeLeft % 12
        
        self.yearsLeftLabel.text! = String(yearsLeft) + "yr"
        self.monthsLeftLabel.text! = String(remainingMonthsLeft) + "mo"
    }
    
    
    func layoutNavigationBar() {
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.black
        self.navigationItem.title = "Balance"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(toAmortizationTables))
    }
    
    
    func layoutChart() {
        // TODO: Implement double Ring Graph
    }
    
    
    @IBAction func addPaymentButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toExtraPayment", sender: self)
    }
    
    
    func toAmortizationTables() {
        let storyboard = UIStoryboard.init(name: "Amortization", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AmortizationVC") as! AmortizationVC
        controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        controller.mortgage = self.mortgage
        self.navigationController?.pushViewController(controller, animated: true)
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExtraPayment" {
            let dest = segue.destination as! ExtraPaymentVC
            dest.mortgage = self.mortgage
        }
    }

}
