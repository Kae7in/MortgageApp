//
//  MortgageCalculator.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation


class MortgageCalculator: NSObject {
    
    /// Used to round decimals to the nearest cent
    func roundDecimals(num: NSDecimalNumber) -> NSDecimalNumber {
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
                                             scale: 2, raiseOnExactness: false,
                                             raiseOnOverflow: false,
                                             raiseOnUnderflow: false,
                                             raiseOnDivideByZero: false)
        let rounded = num.rounding(accordingToBehavior: handler)
        return rounded
    }
    
    
    /// Returns the total amount of extra money to be paid on the given month (loanMonth)
    func calculateExtraPayment(mortgage: Mortgage, loanMonth: Int) -> NSDecimalNumber {
        var totalExtra = 0
        
        if (mortgage.extras.count > 0) {
            // iterate through all the extra payments made on this mortgage
            for i in 0..<mortgage.extras.count {
                var extra = mortgage.extras[i]
                
                // get the relevant properties of the extra payment
                let startMonth: Int = extra["startMonth"] as! Int
                let endMonth: Int = extra["endMonth"] as! Int
                let extraIntervalMonths: Int = extra["extraIntervalMonths"] as! Int
                let extraAmount: Int = extra["extraAmount"] as! Int
                
                // check if loanMonth falls within the time-range of this extra payment
                if (loanMonth >= startMonth && loanMonth <= endMonth) {
                    // check if loanMonth is the current interval month
                    if ((loanMonth - startMonth) % extraIntervalMonths == 0) {
                        totalExtra += extraAmount * 100
                    }
                }
            }
        }
        
        return NSDecimalNumber(value: totalExtra)
    }
    
    
    /// Get the monthly interest for a given APR
    func aprToMonthlyInterest(apr: NSDecimalNumber) -> NSDecimalNumber {
        // apr / (12 * 100)
        return apr.dividing(by: NSDecimalNumber(value: 12).multiplying(by: NSDecimalNumber(value: 100)))
    }
    
    
    /// Get the monthly property tax based on the mortgage's annual propertyTaxRate property
    func calculatePropertyTax(mortgage: Mortgage) -> NSDecimalNumber {
        var monthlyPropertyTax: NSDecimalNumber
        
        // if mortgage.propertyTaxRate > 0
        if (mortgage.propertyTaxRate.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedDescending) {
            // monthlyPropertyTax = (mortgage.salePrice * 100 * (options.propertyTaxRate / 100)) / 12
            monthlyPropertyTax = (mortgage.salePrice.multiplying(by: NSDecimalNumber(value: 100))  // multiply by 100 so we're not dealing with decimals in the calculation
                                .multiplying(by: mortgage.propertyTaxRate.dividing(by: NSDecimalNumber(value: 100)))
                                .dividing(by: NSDecimalNumber(value: 12)))
        } else {
            monthlyPropertyTax = 0
        }
        
        return monthlyPropertyTax
    }
    
    
    /// For ARM Mortgage: Returns boolean indicating that the interest is to be adjusted
    func needsInterestReset(mortgage: Mortgage, loanMonth: Int) -> Bool {
        if (mortgage.adjustFixedRateMonths <= 0 || loanMonth <= mortgage.adjustFixedRateMonths) {
            // either adjustFixedRateMonths is negative (ERROR)
            // or the given month isn't at the first adjustable period, yet
            return false
        }
        
        // heuristic for adjustable rate mortgages
        return (loanMonth - mortgage.adjustFixedRateMonths - 1) % mortgage.adjustIntervalMonths == 0
    }
    
    
    /// Returns the interest rate for a given month (loanMonth), which can vary with ARMs
    func calculateInterestRate(mortgage: Mortgage, loanMonth: Int) -> NSDecimalNumber {
        if (mortgage.adjustFixedRateMonths <= 0 || loanMonth <= mortgage.adjustFixedRateMonths) {
            // either adjustFixedRateMonths is negative (ERROR)
            // or the given month isn't at the first adjustable period, yet
            return mortgage.interestRate
        }
        
        var armInterestRate: NSDecimalNumber = mortgage.interestRate.adding(mortgage.adjustInitialCap)
        if (loanMonth > mortgage.adjustFixedRateMonths + 1) {
            // iterate through and add each adjustment interval up to the given month (loanMonth)
            for _ in stride(from: mortgage.adjustFixedRateMonths + mortgage.adjustIntervalMonths, to: loanMonth, by: mortgage.adjustIntervalMonths) {
                armInterestRate = armInterestRate.adding(mortgage.adjustPeriodicCap)
            }
        }
        
        // essentially min(armInterestRate, mortgage.adjustLifetimeCap + mortgage.interestRate)
        let temp = mortgage.adjustLifetimeCap.adding(mortgage.interestRate)
        let comp: ComparisonResult = armInterestRate.compare(temp)
        if comp == ComparisonResult.orderedDescending {
            armInterestRate = temp
        }
        
        return armInterestRate
    }
    
    
    /// Get the recurring monthly payment (NOT including extra payments) for the given mortgage
    func calculateMonthlyPayment(loanAmount: NSDecimalNumber, loanTermMonths: Int, interestRate: NSDecimalNumber) -> NSDecimalNumber {
        let monthlyInterestRate: NSDecimalNumber = aprToMonthlyInterest(apr: interestRate)
        
        // apply interest rate to the loan amount to calculate the recurring monthly payment (PI)
        let powerRaise: NSDecimalNumber = monthlyInterestRate.adding(NSDecimalNumber(value:1))
                                        .raising(toPower: loanTermMonths)
        let monthlyPayment = loanAmount.multiplying(by: monthlyInterestRate.multiplying(by: powerRaise))
                                        .dividing(by: powerRaise.subtracting(NSDecimalNumber(value: 1)))
        
        return monthlyPayment
    }
    
    
    /// Processes and returns the given mortgage
    func calculateMortgage(mortgage: Mortgage) -> Mortgage {
        calculateAmortizations(mortgage: mortgage)
        return mortgage
    }
    
    
    /// Populates the paymentSchedule[Amortization] array and initializes additional properties for the given mortgage instance
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
        var currentMonthlyPaymentInCents = calculateMonthlyPayment(loanAmount: remainingLoanAmountInCents,
                                                                   loanTermMonths: mortgage.loanTermMonths,
                                                                   interestRate: currentInterestRate)
        let rollupSummaryFields = ["interest", "principal", "extra", "principalTotal", "propertyTax", "paymentTotal"]
        
        /*
         What follows is property assignments to the amortization instance
         declared below followed by updating them in prep for the next iteration
         of the loop. Each amortization instance is stored inside the paymentSchedule
         array on the given mortgage instance.
        */
        while remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedSame
            || remainingLoanAmountInCents.compare(NSDecimalNumber(value: 1)) == ComparisonResult.orderedDescending {
            loanMonth += 1
            let amortization = Amortization() // amortization instance for this period
            
            // may only return true if this is an ARM (if the adjustable* properties on the mortgage instance are not the default)
            if needsInterestReset(mortgage: mortgage, loanMonth: loanMonth) {
                currentInterestRate = calculateInterestRate(mortgage: mortgage, loanMonth: loanMonth)
                currentMonthlyPaymentInCents = calculateMonthlyPayment(loanAmount: remainingLoanAmountInCents, loanTermMonths: mortgage.loanTermMonths + 1 - loanMonth, interestRate: currentInterestRate)
            }
            
            amortization.interestRate = currentInterestRate
            amortization.scheduledMonthlyPayment = currentMonthlyPaymentInCents
            amortization.interest = remainingLoanAmountInCents.multiplying(by: aprToMonthlyInterest(apr: amortization.interestRate))  // interest component of this month's payment
            amortization.principal = currentMonthlyPaymentInCents.subtracting(amortization.interest)  // principal component of this month's payment
            
            if remainingLoanAmountInCents.compare(amortization.principal) == ComparisonResult.orderedAscending {
                // this is the last payment in the mortgage
                amortization.principal = remainingLoanAmountInCents
                amortization.extra = 0
            } else {
                amortization.extra = calculateExtraPayment(mortgage: mortgage, loanMonth: loanMonth)
            }
            
            amortization.principalTotal = amortization.principal.adding(amortization.extra)  // total principal paid so far
            amortization.propertyTax = monthlyPropertyTaxInCents
            amortization.paymentTotal = amortization.interest.adding(amortization.principalTotal.adding(monthlyPropertyTaxInCents))  // total P+I paid so far
                
            // calculate this month's payment date
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
            
            // populate loanYearRollupSummary (a summary of data just for this year)
            // TODO: Can probably get rid of this since we're using the Amortization class, anyway
            _ = rollupSummaryFields.map({ (field: String) in
                if loanYearRollUpSummary[field] != nil {
                    loanYearRollUpSummary[field] = loanYearRollUpSummary[field]?.adding(amortization.value(forKey: field) as! NSDecimalNumber)
                } else {
                    loanYearRollUpSummary[field] = amortization.value(forKey: field) as! NSDecimalNumber?
                }
                
                amortization.setValue(loanYearRollUpSummary[field], forKey: field + "LoanYearToDate")
            })
            
            // reset the loanYearRollupSummary when we turn over a new year
            if loanMonth % 12 == 0 {
                loanYearRollUpSummary = [String: NSDecimalNumber]()
                loanYear += 1
            }
            
            // sum the previous amortization's fields with the current amortization
            // only for the properties whereby we're tracking totals
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
        
        
        // round all amortization values to dollars
        mortgage.totalLoanCost = 0
        let additionalFieldsToProcess = ["scheduledMonthlyPayment", "remainingLoanBalance"]
        
        // assign the total-fields (like interestToDate) we rolled up over time to its appropriate month
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
