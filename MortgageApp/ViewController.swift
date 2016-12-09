
//  ViewController.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var m = Mortgage()
        let c = MortgageCalculator()
        
        m.downPayment = "0%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":100]]
        
        m = c.calculateMortgage(mortgage: m)
        let loanPeriod = 37
        let mirror = Mirror(reflecting: m.paymentSchedule[loanPeriod])
        for child in mirror.children {
            print(child)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

