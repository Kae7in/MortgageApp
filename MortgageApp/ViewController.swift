
//  ViewController.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var principal: UITextField!
    @IBOutlet weak var apr: UITextField!
    @IBOutlet weak var termYears: UITextField!
    @IBOutlet weak var downPercent: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var m = Mortgage()
//        let c = MortgageCalculator()
//        
//        m.downPayment = "0%"
//        m.interestRate = 3.6
//        m.loanTermMonths = 360
//        m.salePrice = 200000
//        m.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":100], ["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":1000]]
//        
//        m = c.calculateMortgage(mortgage: m)
//        let loanPeriod = 100
//        let mirror = Mirror(reflecting: m.paymentSchedule[loanPeriod])
//        for child in mirror.children {
//            print(child)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mortgageSubmitted(_ sender: UIButton) {
        if validateInput() {
            performSegue(withIdentifier: "toMortgageDetail", sender: nil)
        } else {
            performSegue(withIdentifier: "toIntro", sender: nil)
        }
    }
    
    func validateInput() -> Bool {
        if principal.text!.isEmpty
            || apr.text!.isEmpty
            || termYears.text!.isEmpty
            || downPercent.text!.isEmpty
        {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toMortgageDetail" {
            let m = Mortgage()
            m.salePrice = NSDecimalNumber(value: Double(self.principal.text!)!)
            m.interestRate = NSDecimalNumber(value: Double(self.apr.text!)!)
            m.loanTermMonths = Int(self.termYears.text!)! * 12
            m.downPayment = self.downPercent.text! + "%"
            
            let mortgageDetailVC = segue.destination as! MortgageDetailVC
            mortgageDetailVC.m = m
        }
    }

}

