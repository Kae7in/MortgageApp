//
//  MortgageDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import HGCircularSlider

class MortgageDetailVC: UIViewController {
    
    
    var mortgage: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceCents: UILabel!
    @IBOutlet weak var yearsLeftLabel: UILabel!
    @IBOutlet weak var monthsLeftLabel: UILabel!
//    @IBOutlet weak var circleGraph: CircleGraphView!
    @IBOutlet weak var principalRingGraph: CircularSlider!
    @IBOutlet weak var interestRingGraph: CircularSlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mortgage = mc.calculateMortgage(mortgage: mortgage!)
        layoutViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateLabels(balanceLeft: mortgage!.loanAmount().adding(mortgage!.totalLoanCost), timeLeft: self.mortgage!.numberOfPayments)
        self.layoutChart()
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
        let period = self.mortgage!.currentPeriod() - 1
        let maxPrincipal: CGFloat = CGFloat(self.mortgage!.loanAmount().floatValue)
        let principalProgress: CGFloat = CGFloat(self.mortgage!.paymentSchedule[period].principalTotalToDate.floatValue)
        let maxInterest: CGFloat = CGFloat(self.mortgage!.originalMortgage!.totalLoanCost.floatValue)
        let interestProgress: CGFloat = CGFloat(self.mortgage!.paymentSchedule[period].interestToDate.adding(self.mortgage!.totalInterestSavings()).floatValue)
        
        self.principalRingGraph.isUserInteractionEnabled = false
        self.principalRingGraph.lineWidth = 15.0
        self.principalRingGraph.backgroundColor = UIColor.clear
        self.principalRingGraph.endThumbImage = UIImage()
        self.principalRingGraph.diskColor = UIColor.clear
        self.principalRingGraph.trackFillColor = UIColor.primary()
        self.principalRingGraph.trackColor = UIColor.primary(alpha: 0.05)
        self.principalRingGraph.minimumValue = 0.0
        self.principalRingGraph.maximumValue = maxPrincipal
        self.principalRingGraph.endPointValue = principalProgress
        
        self.interestRingGraph.isUserInteractionEnabled = false
        self.interestRingGraph.lineWidth = 15.0
        self.interestRingGraph.backgroundColor = UIColor.clear
        self.interestRingGraph.endThumbImage = UIImage()
        self.interestRingGraph.diskColor = UIColor.clear
        self.interestRingGraph.trackFillColor = UIColor.secondary()
        self.interestRingGraph.trackColor = UIColor.secondary(alpha: 0.05)
        self.interestRingGraph.minimumValue = 0.0
        self.interestRingGraph.maximumValue = maxInterest
        self.interestRingGraph.endPointValue = interestProgress
    }
    
    
    @IBAction func addPaymentButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "ExtraPayments", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ExtraPaymentVC") as! ExtraPaymentVC
        controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        controller.mortgage = self.mortgage
        self.present(controller, animated: true) {
        }
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
}
