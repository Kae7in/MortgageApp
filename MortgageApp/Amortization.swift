//
//  Amortization.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/8/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation

class Amortization: NSObject {
    var extra: NSDecimalNumber = 0.0
    var extraLoanYearToDate: NSDecimalNumber = 0.0
    var extraToDate: NSDecimalNumber = 0.0
    var interest: NSDecimalNumber = 0.0
    var interestLoanYearToDate: NSDecimalNumber = 0.0
    var interestRate: NSDecimalNumber = 0.0
    var interestSaved: NSDecimalNumber = 0.0
    var interestSavedToDate: NSDecimalNumber = 0.0
    var interestToDate: NSDecimalNumber = 0.0
    var loanMonth: Int = 0
    var loanYear: Int = 0
    var paymentDate: Date = Date()
    var paymentTotal: NSDecimalNumber = 0.0
    var paymentTotalLoanYearToDate: NSDecimalNumber = 0.0
    var paymentTotalToDate: NSDecimalNumber = 0.0
    var principal: NSDecimalNumber = 0.0
    var principalLoanYearToDate: NSDecimalNumber = 0.0
    var principalToDate: NSDecimalNumber = 0.0
    var principalTotal: NSDecimalNumber = 0.0
    var principalTotalLoanYearToDate: NSDecimalNumber = 0.0
    var principalTotalToDate: NSDecimalNumber = 0.0
    var propertyTax: NSDecimalNumber = 0.0
    var propertyTaxLoanYearToDate: NSDecimalNumber = 0.0
    var propertyTaxToDate: NSDecimalNumber = 0.0
    var remainingLoanBalance: NSDecimalNumber = 0.0
    var remainingLoanCost: NSDecimalNumber = 0.0
    var scheduledMonthlyPayment: NSDecimalNumber = 0.0
}
