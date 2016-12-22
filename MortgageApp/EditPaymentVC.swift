//
//  EditPaymentVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/20/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class EditPaymentVC: UIViewController {
    
    var m: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()

    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var interestSavings: UILabel!
    @IBOutlet weak var extraPaymentSlider: UISlider!
    @IBOutlet weak var extraPaymentLabel: UILabel!
    @IBOutlet weak var paymentTypeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
//        navbar.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 200, green: 200, blue: 200, alpha: 1.0)]
    }
    
    func updateLabels() {
//        let yearsSaved = self.m!.monthsSaved() / 12
//        let remainingMonthsSaved = self.m!.monthsSaved() % 12
        //principal.text = "$" + String(describing: m!.loanAmount())
        //interest.text = "$" + String(describing: m!.totalLoanCost).components(separatedBy: ".")[0]
        interestSavings.text! = "$" + String(describing: self.m?.originalMortgage!.totalLoanCost.subtracting(m!.totalLoanCost)).components(separatedBy: ".")[0]
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
