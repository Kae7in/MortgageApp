//
//  Mortgage.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation

class Mortgage: NSObject {
    var loanTermMonths: Int = 360
    var salePrice: NSDecimalNumber = 200000
    var interestRate: NSDecimalNumber = 3.6
    var downPayment: String = "20%"
    var extras: [Dictionary<String,Int>] = []
    var propertyTaxRate: NSDecimalNumber = 0
    var homeInsurance: NSDecimalNumber = 0
    var adjustFixedRateMonths: Int = 0
    var adjustInitialCap: NSDecimalNumber = 0
    var adjustPeriodicCap: NSDecimalNumber = 0
    var adjustLifetimeCap: NSDecimalNumber = 0
    var adjustIntervalMonths: Int = 12
    var startDate = Date()
    
    func loanAmount() -> NSDecimalNumber {
        var str = self.downPayment
        let i = str.characters.index(of: "%")!
        let downPercent = NSDecimalNumber(string: str.substring(to: i))
        let loanAmount = self.salePrice.subtracting(self.salePrice.multiplying(by: downPercent.dividing(by: 100)))
        return loanAmount
    }
}
