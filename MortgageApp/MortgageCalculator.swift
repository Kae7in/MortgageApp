//
//  MortgageCalculator.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation


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
                let startMonth: Int = extra["startMonth"] as! Int
                let endMonth: Int = extra["endMonth"] as! Int
                let extraIntervalMonths: Int = extra["extraIntervalMonths"] as! Int
                let extraAmount: Int = extra["extraAmount"] as! Int
                
                if (loanMonth >= startMonth && loanMonth <= endMonth) {
                    if ((loanMonth - startMonth) % extraIntervalMonths == 0) {
                        totalExtra += extraAmount * 100
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
        let monthlyPropertyTaxInCents = calculatePropertyTax(mortgage: mortgage)
        var amortizations = [Amortization]()
        var previousAmortization: Amortization? = nil
        var loanMonth = 0
        var loanYear = 1
        var loanYearRollUpSummary = [String: NSDecimalNumber]()
        var currentInterestRate = calculateInterestRate(mortgage: mortgage, loanMonth: 1)
        var currentMonthlyPaymentInCents = calculateMonthlyPayment(loanAmount: remainingLoanAmountInCents, loanTermMonths: mortgage.loanTermMonths, interestRate: currentInterestRate)
        let rollupSummaryFields = ["interest", "principal", "extra", "principalTotal", "propertyTax", "paymentTotal"]
        
        while remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedSame || remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedDescending {
            loanMonth += 1
            let amortization = Amortization()
            
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
            _ = rollupSummaryFields.map({ (field: String) in
                if loanYearRollUpSummary[field] != nil {
                    loanYearRollUpSummary[field] = loanYearRollUpSummary[field]?.adding(amortization.value(forKey: field) as! NSDecimalNumber)
                } else {
                    loanYearRollUpSummary[field] = amortization.value(forKey: field) as! NSDecimalNumber?
                }
                
                amortization.setValue(loanYearRollUpSummary[field], forKey: field + "LoanYearToDate")
            })
            
            if loanMonth % 12 == 0 {
                loanYearRollUpSummary = [String: NSDecimalNumber]()
                loanYear += 1
            }
            
            _ = rollupSummaryFields.map({ (field: String) in
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
            _ = rollupSummaryFields.map({ (field: String) in
                var temp: NSDecimalNumber = amortization.value(forKey: field) as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field)
                temp = amortization.value(forKey: field + "ToDate") as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field + "ToDate")
                temp = amortization.value(forKey: field + "LoanYearToDate") as! NSDecimalNumber
                amortization.setValue(roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100))), forKey: field + "LoanYearToDate")
            })
            
            _ = additionalFieldsToProcess.map({ (field: String) in
                let temp = amortization.value(forKey: field) as! NSDecimalNumber
                let val = roundDecimals(num: temp.dividing(by: NSDecimalNumber(value: 100)))
                amortization.setValue(val, forKey: field)
            })
            
            mortgage.totalLoanCost = mortgage.totalLoanCost.adding(amortization.interest)
        }
        
        mortgage.totalLoanCost = roundDecimals(num: mortgage.totalLoanCost)
        mortgage.paymentSchedule = amortizations
        mortgage.setOriginalPaymentSchedule()
        mortgage.numberOfPayments = mortgage.paymentSchedule.count
        mortgage.monthlyPayment = mortgage.paymentSchedule[0].scheduledMonthlyPayment  // TODO: Make this the current month's payment (e.g. what if the user is creating an ARM mortgage after having it for 10 years? Could be a different monthly payment)
        mortgage.calculateAdditionalMetrics()
    }
    
}
