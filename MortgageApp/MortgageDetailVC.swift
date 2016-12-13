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
    var originalTotalLoanCost: NSDecimalNumber? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var principal: UILabel!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var futureInterestSavings: UILabel!
    @IBOutlet weak var extraPaymentSlider: UISlider!
    @IBOutlet weak var extraPaymentLabel: UILabel!
    @IBOutlet weak var paymentTypeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        m = mc.calculateMortgage(mortgage: m!)
        originalTotalLoanCost = m!.totalLoanCost
        updateLabels()
    }
    
    func updateLabels() {
        balance.text = "$" + String(describing: m!.loanAmount().adding(m!.totalLoanCost)).components(separatedBy: ".")[0]
        principal.text = "$" + String(describing: m!.loanAmount())
        interest.text = "$" + String(describing: m!.totalLoanCost).components(separatedBy: ".")[0]
        futureInterestSavings.text = "$" + String(describing: originalTotalLoanCost!.subtracting(m!.totalLoanCost)).components(separatedBy: ".")[0]
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        if paymentTypeControl.selectedSegmentIndex == 0 {
            m?.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]
        } else {
            m?.extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]
        }
        m = mc.calculateMortgage(mortgage: m!)
        updateLabels()
    }
    
    @IBAction func sliderChangedC(_ sender: UISlider) {
        extraPaymentLabel.text = "$" + String(Int(extraPaymentSlider.value))
    }
    
    
    @IBAction func paymentTypeChanged(_ sender: Any) {
        if paymentTypeControl.selectedSegmentIndex == 0 {
            m?.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]
        } else {
            m?.extras = [["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":Int(extraPaymentSlider.value)]]
        }
        m = mc.calculateMortgage(mortgage: m!)
        updateLabels()
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
