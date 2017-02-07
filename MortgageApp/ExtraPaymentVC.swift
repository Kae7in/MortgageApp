//
//  ExtraPaymentVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/20/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ExtraPaymentVC: UIViewController {
    
    var mortgage: Mortgage? = nil
    var extra: Dictionary<String, Any>? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    var ref: FIRDatabaseReference!

    @IBOutlet weak var navbar: UINavigationItem!
    
    @IBOutlet weak var principalBalance: UILabel!
    @IBOutlet weak var interestBalance: UILabel!
    @IBOutlet weak var yearsBalance: UILabel!
    @IBOutlet weak var monthsBalance: UILabel!
    @IBOutlet weak var interestSavings: UILabel!
    @IBOutlet weak var yearsSavings: UILabel!
    @IBOutlet weak var monthsSavings: UILabel!
    
    @IBOutlet weak var extraPaymentSlider: UISlider!
    @IBOutlet weak var extraPaymentLabel: UILabel!
    @IBOutlet weak var paymentTypeControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        layoutViews()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutViews()
    }
    
    
    func layoutViews() {
        layoutNavigationBar()
    }
    
    
    func layoutNavigationBar() {
        navbar.title = "Extra Payment"
        navbar.rightBarButtonItem?.target = self
        navbar.rightBarButtonItem?.action = #selector(saveButton(sender:))
        navbar.leftBarButtonItem?.target = self
        navbar.leftBarButtonItem?.action = #selector(cancelButton(sender:))
    }
    
    
    func updatePrincipalBalanceLabel(value: NSDecimalNumber) {
        self.principalBalance.text! = "$" + String(describing: value).components(separatedBy: ".").first!
    }
    
    
    func updateInterestBalanceLabel(value: NSDecimalNumber) {
        self.interestBalance.text! = "$" + String(describing: value).components(separatedBy: ".").first!
    }
    
    
    func updateTimeBalanceLabels(monthsLeft: Int) {
        let yearsLeft = monthsLeft / 12
        let monthsRemainder = monthsLeft % 12
        
        self.yearsBalance.text! = String(yearsLeft) + "yr"
        self.monthsBalance.text! = String(monthsRemainder) + "mo"
    }
    
    
    func updateExtraPaymentLabel(value: Float) {
        extraPaymentLabel.text = "$" + String(Int(value))
    }
    
    
    func updateInterestSavingsLabel(value: NSDecimalNumber) {
        interestSavings.text = "$" + String(describing: value).components(separatedBy: ".")[0]
    }
    
    
    func updateTimeSavingsLabels(months: Int) {
        let yearsSaved = months / 12
        let monthsSavedRemainder = months % 12
        
        self.yearsSavings.text! = String(yearsSaved) + "yr"
        self.monthsSavings.text! = String(monthsSavedRemainder) + "mo"
    }
    
    
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
        updateMortgageMetrics()
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateExtraPaymentLabel(value: self.extraPaymentSlider.value)
    }
    
    
    @IBAction func paymentTypeChanged(_ sender: UISegmentedControl) {
        if self.extra != nil {
            updateMortgageMetrics()
        }
    }
    
    
    func updateMortgageMetrics() {
        if paymentTypeControl.selectedSegmentIndex == 0 {
            self.extra = ["startMonth":self.mortgage!.currentPeriod(),
                       "endMonth":360,
                       "extraIntervalMonths":1,
                       "extraAmount":Int(extraPaymentSlider.value)]
        } else {
            self.extra = ["startMonth":self.mortgage!.currentPeriod(),
                       "endMonth":self.mortgage!.currentPeriod(),
                       "extraIntervalMonths":1,
                       "extraAmount":Int(extraPaymentSlider.value)]
        }
        
        var newMortgage = Mortgage(self.mortgage!)
        newMortgage.extras.append(extra!)
        newMortgage = mc.calculateMortgage(mortgage: newMortgage)
        
        updateExtraPaymentLabel(value: self.extraPaymentSlider.value)
        updatePrincipalBalanceLabel(value: newMortgage.paymentSchedule[self.mortgage!.currentPeriod() - 1].remainingLoanBalance)
        updateInterestBalanceLabel(value: newMortgage.totalLoanCost)
        updateTimeBalanceLabels(monthsLeft: newMortgage.paymentSchedule.count)  // TODO: Subtract today's date from the paymentSchedule
        updateInterestSavingsLabel(value: newMortgage.totalInterestSavings().subtracting(self.mortgage!.totalInterestSavings()))
        updateTimeSavingsLabels(months: self.mortgage!.numberOfPayments - newMortgage.numberOfPayments)
    }
    
    
    func saveButton(sender: UIBarButtonItem) {
        if self.extra != nil {
            // append the new extra to the global mortgage instance
            self.mortgage?.extras.append(self.extra!)
            
            // run it through the calculator to update all of its values
            _ = self.mc.calculateMortgage(mortgage: self.mortgage!)
            
            // save the global mortgage instance before dismissing the view
            self.mortgage?.save()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func cancelButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
