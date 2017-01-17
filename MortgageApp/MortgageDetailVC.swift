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
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1.0)
        self.navigationItem.title = "Balance"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(extraPaymentButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
    }
    
    
    func layoutChart() {
        // TODO: Implement double Ring Graph
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func extraPaymentButtonAction(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toEditPayment", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ExtraPaymentVC
        
        dest.mortgage = self.mortgage
    }

}
