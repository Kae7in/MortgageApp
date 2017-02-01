//
//  Amortization.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/8/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation


/**
 The Amortization class is fairly synonymous with the terms "period" or "month".
 It represents a single period in the payment schedule of a mortgage. The properties
 of the Amortization object reflect the state they're in at the time this period occurs.
 
 The properties on this object are useful when comparing what this month would have been
 like had the user not made any extra payments.
 
 For a 30 year mortgage, there are 360 of these objects in the Mortgage's payment schedule.
 */
class Amortization: NSObject {
    /// extra principal paid this period
    var extra: NSDecimalNumber = 0.0
    
    /// extra principal paid so far this year
    var extraLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total extra principal to date (from period 1 up until now)
    var extraToDate: NSDecimalNumber = 0.0
    
    /// interest component of the payment for this period
    var interest: NSDecimalNumber = 0.0
    
    /// interest paid so far this year
    var interestLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total interest paid to date
    var interestToDate: NSDecimalNumber = 0.0
    
    /// interest rate used this period
    var interestRate: NSDecimalNumber = 0.0
    
    /// interest saved this period
    var interestSaved: NSDecimalNumber = 0.0
    
    /// total interest saved to date
    var interestSavedToDate: NSDecimalNumber = 0.0
    
    /// 1-indexed period/month number in lifespan of the mortgage (ex. 1 year into mortgage == 13)
    var loanMonth: Int = 0
    
    /// 1-indexed year number in lifespan of the mortgage (ex. 2 years into mortgage == 2)
    var loanYear: Int = 0
    
    /// date of this month's payment
    var paymentDate: Date = Date()
    
    /// extra principal + PITI paid this month
    var paymentTotal: NSDecimalNumber = 0.0
    
    /// extra principal + PITI paid this year to date
    var paymentTotalLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total extra principal + PITI paid to date
    var paymentTotalToDate: NSDecimalNumber = 0.0
    
    /// NON-etra principal component of the payment for this period
    var principal: NSDecimalNumber = 0.0
    
    /// NON-extra principal paid so far this year
    var principalLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total NON-extra principal paid to date
    var principalToDate: NSDecimalNumber = 0.0
    
    /// principal component of the payment for this period
    var principalTotal: NSDecimalNumber = 0.0
    
    /// principal paid so far this year
    var principalTotalLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total principal paid to date
    var principalTotalToDate: NSDecimalNumber = 0.0
    
    /// property tax component of this period's payment
    var propertyTax: NSDecimalNumber = 0.0
    
    /// property tax paid so far this year
    var propertyTaxLoanYearToDate: NSDecimalNumber = 0.0
    
    /// total property tax paid to date
    var propertyTaxToDate: NSDecimalNumber = 0.0
    
    /// principal owed until mortgage payoff
    var remainingLoanBalance: NSDecimalNumber = 0.0
    
    /// interest owed until mortgage payoff
    var remainingLoanCost: NSDecimalNumber = 0.0
    
    /// PITI scheduled to be owed this month (original payment, without extra)
    var scheduledMonthlyPayment: NSDecimalNumber = 0.0
}
