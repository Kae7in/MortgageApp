//
//  Amortization.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/8/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation

class Amortization: NSObject {
    var monthlyPayment: NSDecimalNumber = 0.0
    var interestRate: NSDecimalNumber = 0.0
    var interest: NSDecimalNumber = 0.0
    var interestToDate: NSDecimalNumber = 0.0
    var interestLoanYearToDate: NSDecimalNumber = 0.0
    var principal: NSDecimalNumber = 0.0
    var principalLoanYearToDate: NSDecimalNumber = 0.0
    var principalToDate: NSDecimalNumber = 0.0
    var extra: NSDecimalNumber = 0.0
    var principalTotal: NSDecimalNumber = 0.0
    var paymentTotal: NSDecimalNumber = 0.0
}
