//
//  EditPaymentVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/20/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditPaymentVC: UIViewController {
    
    var mortgage: Mortgage? = nil
    var newMortgage: Mortgage!
    var newM: Mortgage? = nil
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
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        layoutViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        updateMortgageMetrics()
    }
    
    @IBAction func paymentTypeChanged(_ sender: UISegmentedControl) {
        updateMortgageMetrics()
    }
    
    func updateMortgageMetrics() {
        var extras = [Dictionary<String, Int>]()
        
        if paymentTypeControl.selectedSegmentIndex == 0 {
            extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]  // TODO: Use current period as startMonth
        } else {
            extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]  // TODO: Use current period as start months
        }
        
        self.newMortgage = calculateNewMortgageFromExtras(mortgage: self.mortgage!, newExtras: extras)
        
        updateExtraPaymentLabel(value: self.extraPaymentSlider.value)
        updatePrincipalBalanceLabel(value: newMortgage.paymentSchedule.first!.remainingLoanBalance)  // TODO: Use current period
        updateInterestBalanceLabel(value: newMortgage.totalLoanCost)
        updateTimeBalanceLabels(monthsLeft: newMortgage.paymentSchedule.count)  // TODO: Subtract today's date from the paymentSchedule
        updateInterestSavingsLabel(value: newMortgage.totalInterestSavings())
        updateTimeSavingsLabels(months: newMortgage.originalMortgage!.loanTermMonths - newMortgage.paymentSchedule.count)
        updateInterestSavingsLabel(value: newMortgage.totalInterestSavings())
    }
    
    func calculateNewMortgageFromExtras(mortgage: Mortgage, newExtras: [Dictionary<String, Int>]) -> Mortgage {
        var newM = Mortgage(mortgage)
        for extra in newExtras {
            newM.extras.append(extra)
        }
        newM = mc.calculateMortgage(mortgage: newM)
        return newM
    }
    
    func saveButton(sender: UIBarButtonItem) {
        if self.mortgage?.extras.count != self.newMortgage.extras.count {
            self.newMortgage.save()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func cancelButton(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
