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
    
    func calculateMortgage(mortgage: Mortgage) -> Mortgage {
        calculateAmortizations(mortgage: mortgage)
        return mortgage
    }
    
    func calculateAmortizations(mortgage: Mortgage) {
        // To avoid rounding errors, all dollars will be converted to cents and converted back to dollars
        var remainingLoanAmountInCents = mortgage.loanAmount().multiplying(by: NSDecimalNumber(value: 100))
        var monthlyPropertyTaxInCents = calculatePropertyTax(mortgage: mortgage)
        var amortizations = [Amortization]()
        var previousAmortization: Amortization? = nil
        var loanMonth = 0
        var loanYear = 1
        var loanYearRollUpSummary = [String: NSDecimalNumber]()
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
            
            amortization.interestRate = currentInterestRate
            amortization.scheduledMonthlyPayment = currentMonthlyPaymentInCents
            amortization.interest = remainingLoanAmountInCents.multiplying(by: aprToMonthlyInterest(apr: amortization.interestRate))
            amortization.principal = currentMonthlyPaymentInCents.subtracting(amortization.interest)
            
            if remainingLoanAmountInCents.compare(amortization.principal) == ComparisonResult.orderedAscending {
                amortization.principal = remainingLoanAmountInCents
                amortization.extra = 0
            } else {
                amortization.extra = calculateExtraPayment(mortgage: mortgage, loanMonth: loanMonth)
            }
            
            amortization.principalTotal = amortization.principal.adding(amortization.extra)
            amortization.propertyTax = monthlyPropertyTaxInCents
            amortization.paymentTotal = amortization.interest.adding(amortization.principalTotal.adding(monthlyPropertyTaxInCents))
            var comps = DateComponents()
            comps.setValue(loanMonth, for: Calendar.Component.month)
            amortization.paymentDate = Calendar.current.date(byAdding: comps, to: mortgage.startDate)!
            remainingLoanAmountInCents = remainingLoanAmountInCents.subtracting(amortization.principalTotal)
            
            if remainingLoanAmountInCents.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedAscending {
                remainingLoanAmountInCents = 0
            }
            amortization.remainingLoanBalance = remainingLoanAmountInCents
            
            amortization.loanMonth = loanMonth
            amortization.loanYear = loanYear
            rollupSummaryFields.map({ (field: String) in
                if loanYearRollUpSummary[field] != nil {
                    loanYearRollUpSummary[field]?.adding(amortization.value(forKey: field) as! NSDecimalNumber)
                } else {
                    loanYearRollUpSummary[field] = amortization.value(forKey: field) as! NSDecimalNumber?
                }
                
                amortization.setValue(loanYearRollUpSummary[field], forKey: field + "LoanYearToDate")
            })
            
            if loanMonth % 12 == 0 {
                loanYearRollUpSummary = [String: NSDecimalNumber]()
                loanYear += 1
            }
            
            rollupSummaryFields.map({ (field: String) in
                if previousAmortization != nil {
                    let prev: NSDecimalNumber = previousAmortization!.value(forKey: field + "ToDate") as! NSDecimalNumber
                    let cur: NSDecimalNumber = amortization.value(forKey: field) as! NSDecimalNumber
                    let val = prev.adding(cur)
                    amortization.setValue(val, forKey: field + "ToDate")
                } else {
                    amortization.setValue(amortization.value(forKey: field), forKey: field + "ToDate")
                }
            })
            
            previousAmortization = amortization
            amortizations.append(amortization)
        }
        
        
        // Round all amortization values to dollars
        mortgage.totalLoanCost = 0
        let additionalFieldsToProcess = ["scheduledMonthlyPayment", "remainingLoanBalance"]
        
        for i in 0..<amortizations.count {
            let amortization = amortizations[i]
            rollupSummaryFields.map({ (field: String) in
                var temp: NSDecimalNumber = amortization.value(forKey: field) as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field)
                temp = amortization.value(forKey: field + "ToDate") as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field + "ToDate")
                temp = amortization.value(forKey: field + "LoanYearToDate") as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field + "LoanYearToDate")
            })
            
            additionalFieldsToProcess.map({ (field: String) in
                let temp = amortization.value(forKey: field) as! NSDecimalNumber
                let val = roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100)))
                amortization.setValue(val, forKey: field)
            })
            
            mortgage.totalLoanCost.adding(amortization.interest)
        }
        
        mortgage.totalLoanCost = roundDecimals(num: mortgage.totalLoanCost)
        mortgage.paymentSchedule = amortizations
        mortgage.numberOfPayments = mortgage.paymentSchedule.count
        mortgage.monthlyPayment = mortgage.paymentSchedule[0].scheduledMonthlyPayment
    }
    
}
