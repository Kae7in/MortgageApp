//
//  MortgageCalculator.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation

// ADD MONTH EXAMPLE
//var comps = DateComponents()
//comps.setValue(2, for: Calendar.Component.month)
//let date: Date = Date()
//let newDate: Date = Calendar.current.date(byAdding: comps, to: date)!

class MortgageCalculator: NSObject {
    
//    func initOptions(options: Dictionary<String, Any>) -> Mortgage {
//        let m = Mortgage()
//        
//        if (options["loanTermMonths"] != nil) { m.loanTermMonths = NSDecimalNumber(value: options["loanTermMonths"] as! Int) }
//        if (options["salePrice"] != nil) { m.salePrice = NSDecimalNumber(value: options["salePrice"] as! Int) }
//        if (options["interestRate"] != nil) { m.interestRate = NSDecimalNumber(value: options["interestRate"] as! Double) }
//        if (options["downPayment"] != nil) { m.downPayment = options["downPayment"] as! String }
//        if (options["extras"] != nil) { m.extras = options["extras"] as! Array }
//        if (options["propertyTaxRate"] != nil) { m.propertyTaxRate = NSDecimalNumber(value: options["propertyTaxRate"] as! Int) }
//        if (options["homeInsurance"] != nil) { m.homeInsurance = NSDecimalNumber(value: options["homeInsurance"] as! Int) }
//        if (options["adjustFixedRateMonths"] != nil) { m.adjustFixedRateMonths = NSDecimalNumber(value: options["adjustFixedRateMonths"] as! Int) }
//        if (options["adjustInitialCap"] != nil) { m.adjustInitialCap = NSDecimalNumber(value: options["adjustInitialCap"] as! Int) }
//        if (options["adjustPeriodCap"] != nil) { m.adjustPeriodicCap = NSDecimalNumber(value: options["adjustPeriodCap"] as! Int) }
//        if (options["adjustLifetimeCap"] != nil) { m.adjustLifetimeCap = NSDecimalNumber(value: options["adjustLifetimeCap"] as! Int) }
//        if (options["adjustIntervalMonths"] != nil) { m.adjustIntervalMonths = NSDecimalNumber(value: options["adjustIntervalMonths"] as! Int) }
//        if (options["startDate"] != nil) { m.startDate = options["startDate"] as! Date }
//        
//        print(calculateLoanAmount(mortgage: m))
//        
//        return m
//    }
    
    func roundDecimals(num: NSDecimalNumber) -> NSDecimalNumber {
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let rounded = num.rounding(accordingToBehavior: handler)
        return rounded
    }
    
    func calculateExtraPayment(mortgage: Mortgage, loanMonth: Int) -> NSDecimalNumber {
        var totalExtra = 0
        if (mortgage.extras.count > 0) {
            for i in 0..<mortgage.extras.count {
                var extra = mortgage.extras[i]
                if (loanMonth >= extra["startMonth"]! && loanMonth <= extra["endMonth"]! ) {
                    if ((loanMonth - extra["startMonth"]!) % extra["extraIntervalMonths"]! == 0) {
                        totalExtra += extra["extraAmount"]! * 100
                    }
                }
            }
        }
        
        return NSDecimalNumber(value: totalExtra)
    }
    
    func aprToMonthlyInterest(apr: NSDecimalNumber) -> NSDecimalNumber {
        // apr / (12 * 100)
        return apr.dividing(by: NSDecimalNumber(value: 12).multiplying(by: NSDecimalNumber(value: 100)))
    }
    
    func calculatePropertyTax(mortgage: Mortgage) -> NSDecimalNumber {
        var monthlyPropertyTax: NSDecimalNumber
        if (mortgage.propertyTaxRate.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedDescending) {
            // monthlyPropertyTax = (mortgage.salePrice * 100 * (options.propertyTaxRate / 100)) / 12
            monthlyPropertyTax = (mortgage.salePrice.multiplying(by: NSDecimalNumber(value: 100)).multiplying(by: mortgage.propertyTaxRate.dividing(by: NSDecimalNumber(value: 100))).dividing(by: NSDecimalNumber(value: 12)))
        } else {
            monthlyPropertyTax = 0
        }
        return monthlyPropertyTax
    }
    
    func needsInterestReset(mortgage: Mortgage, loanMonth: Int) -> Bool {
        if (mortgage.adjustFixedRateMonths <= 0 || loanMonth <= mortgage.adjustFixedRateMonths) {
            return false
        }
        return (loanMonth - mortgage.adjustFixedRateMonths - 1) % mortgage.adjustIntervalMonths == 0
    }
    
    func calculateInterestRate(mortgage: Mortgage, loanMonth: Int) -> NSDecimalNumber {
        if (mortgage.adjustFixedRateMonths <= 0 || loanMonth <= mortgage.adjustFixedRateMonths) {
            return mortgage.interestRate
        }
        
        var armInterestRate: NSDecimalNumber = mortgage.interestRate.adding(mortgage.adjustInitialCap)
        if (loanMonth > mortgage.adjustFixedRateMonths + 1) {
            for _ in stride(from: mortgage.adjustFixedRateMonths + mortgage.adjustIntervalMonths, to: loanMonth, by: mortgage.adjustIntervalMonths) {
                armInterestRate = armInterestRate.adding(mortgage.adjustPeriodicCap)
            }
        }
        
        let temp = mortgage.adjustLifetimeCap.adding(mortgage.interestRate)
        let comp: ComparisonResult = armInterestRate.compare(temp)
        if comp == ComparisonResult.orderedDescending {
            armInterestRate = temp
        }
        
        return armInterestRate
    }
    
    func calculateMonthlyPayment(loanAmount: NSDecimalNumber, loanTermMonths: Int, interestRate: NSDecimalNumber) -> NSDecimalNumber {
        let monthlyInterestRate: NSDecimalNumber = aprToMonthlyInterest(apr: interestRate)
        
        var powerRaise: NSDecimalNumber = monthlyInterestRate.adding(NSDecimalNumber(value:1))
        powerRaise = powerRaise.raising(toPower: loanTermMonths)
        
        var monthlyPayment = loanAmount.multiplying(by: monthlyInterestRate.multiplying(by: powerRaise))
        monthlyPayment = monthlyPayment.dividing(by: powerRaise.subtracting(NSDecimalNumber(value: 1)))
        
        return monthlyPayment
    }
    
    func calculateAmortizations(mortgage: Mortgage) {
        // To avoid rounding errors, all dollars will be converted to cents and converted back to dollars
        var remainingLoanAmountInCents = mortgage.loanAmount().multiplying(by: NSDecimalNumber(value: 100))
        var loanAmountInCents = mortgage.loanAmount().multiplying(by: NSDecimalNumber(value: 100))
        var monthlyPropertyTaxInCents = calculatePropertyTax(mortgage: mortgage)
        var amortizations = [Amortization]()
        var previousAmortization = Amortization()
        var loanMonth = 0
        var loanYear = 1
        var loanYearRollUpSummary = [String: Any]()
        var currentInterestRate = calculateInterestRate(mortgage: mortgage, loanMonth: 1)
        var currentMonthlyPaymentInCents = calculateMonthlyPayment(loanAmount: remainingLoanAmountInCents, loanTermMonths: mortgage.loanTermMonths, interestRate: currentInterestRate)
        var rollupSummaryFields = ["interest", "principal", "extra", "principalTotal", "propertyTax", "paymentTotal"]
        
        while remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedSame || remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedDescending {
            loanMonth += 1
            var amortization = Amortization()
            
            if needsInterestReset(mortgage: mortgage, loanMonth: loanMonth) {
                currentInterestRate = calculateInterestRate(mortgage: mortgage, loanMonth: loanMonth)
                currentMonthlyPaymentInCents = calculateMonthlyPayment(loanAmount: remainingLoanAmountInCents, loanTermMonths: mortgage.loanTermMonths + 1 - loanMonth, interestRate: currentInterestRate)
            }
            
//            amortization["interestRate"] = currentInterestRate
//            amortization["scheduledMonthlyPayment"] = currentMonthlyPaymentInCents
//            amortization["interset"] = remainingLoanAmountInCents.multiplying(by: aprToMonthlyInterest(apr: amortization["interestRate"] as! NSDecimalNumber))
//            amortization["principal"] = currentMonthlyPaymentInCents
        }
    }
}
