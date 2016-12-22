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
    var totalLoanCost: NSDecimalNumber = 0
    var paymentSchedule = [Amortization]()
    var originalMortgage: Mortgage? = nil
    var numberOfPayments: Int = 360
    var monthlyPayment: NSDecimalNumber = 0
    
    override init() {
        super.init()
    }
    
    init(_ mortgage: Mortgage) {
        self.loanTermMonths = mortgage.loanTermMonths
        self.salePrice = mortgage.salePrice
        self.interestRate = mortgage.interestRate
        self.downPayment = mortgage.downPayment
        self.extras = mortgage.extras
        self.propertyTaxRate = mortgage.propertyTaxRate
        self.homeInsurance = mortgage.homeInsurance
        self.adjustFixedRateMonths = mortgage.adjustFixedRateMonths
        self.adjustInitialCap = mortgage.adjustInitialCap
        self.adjustPeriodicCap = mortgage.adjustPeriodicCap
        self.adjustLifetimeCap = mortgage.adjustLifetimeCap
        self.adjustIntervalMonths = mortgage.adjustIntervalMonths
        self.startDate = mortgage.startDate
        self.totalLoanCost = mortgage.totalLoanCost
        self.paymentSchedule = mortgage.paymentSchedule
        self.originalMortgage = mortgage.originalMortgage
        self.numberOfPayments = mortgage.numberOfPayments
        self.monthlyPayment = mortgage.monthlyPayment
    }
    
    func loanAmount() -> NSDecimalNumber {
        var str = self.downPayment
        let i = str.characters.index(of: "%")!
        let downPercent = NSDecimalNumber(string: str.substring(to: i))
        let loanAmount = self.salePrice.subtracting(self.salePrice.multiplying(by: downPercent.dividing(by: 100)))
        return loanAmount
    }
    
    func totalInterestSavings() -> NSDecimalNumber {
        setOriginalPaymentSchedule()
        return originalMortgage!.totalLoanCost.subtracting(self.totalLoanCost)
    }
    
    func interestSavedForRange(start: Int, end: Int) -> NSDecimalNumber {
        var interestSaved7Years = NSDecimalNumber(value: 0.0)
        for i in start..<end {
            interestSaved7Years = interestSaved7Years.adding(self.paymentSchedule[i].interestSaved)
        }
        return interestSaved7Years
    }
    
    func monthsSaved() -> Int {
        return self.originalMortgage!.numberOfPayments - self.numberOfPayments
    }
    
    // TODO: Bake this into the original amortization calculation
    func setOriginalPaymentSchedule() {
        if originalMortgage != nil {
            // originalMortgage has already been set
            return
        } else {
            // originalMortgage has not yet been set
            if extras.isEmpty {
                self.originalMortgage = Mortgage(self)
            } else {
                var m = Mortgage(self)
                m.extras = []
                m.originalMortgage = m  // Must be set to non-nil value (reference to itself, in this case) so as to no loop infinitely
                let mc = MortgageCalculator()
                m = mc.calculateMortgage(mortgage: m)
                self.originalMortgage = m
            }
        }
    }
    
    // TODO: Bake this into the original amortization calculation
    func calculateAdditionalMetrics() {
        for amortization in paymentSchedule {
            calculateRemainingLoanCostForPeriod(amortization: amortization)
            calculateInterestSavedForPeriod(amortization: amortization)
        }
    }
    
    private func calculateRemainingLoanCostForPeriod(amortization: Amortization) {
        var remainingLoanCost = self.totalLoanCost.subtracting(amortization.interestToDate)
        let compResult: ComparisonResult = remainingLoanCost.compare(NSDecimalNumber(value: 0))
            
        if compResult == ComparisonResult.orderedAscending {
            remainingLoanCost = 0
        }
            
        amortization.remainingLoanCost = remainingLoanCost
    }
    
    private func calculateInterestSavedForPeriod(amortization: Amortization) {
        if !paymentSchedule.isEmpty && !originalMortgage!.paymentSchedule.isEmpty {
            let periodIndex = amortization.loanMonth - 1
            let originalInterest = originalMortgage!.paymentSchedule[periodIndex].interest
            let currentInterest = paymentSchedule[periodIndex].interest
            amortization.interestSaved = originalInterest.subtracting(currentInterest)
        }
    }
}






////
////  Mortgage.swift
////  MortgageApp
////
////  Created by Kaelin Hooper on 12/7/16.
////  Copyright © 2016 Kaelin Hooper. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//class Mortgage: Object {
//    var loanTermMonths: Int = 360
//    var salePrice: NSDecimalNumber = 200000
//    var interestRate: NSDecimalNumber = 3.6
//    var downPayment: String = "20%"
//    var extras: [Dictionary<String,Int>] = []
//    var propertyTaxRate: NSDecimalNumber = 0
//    var homeInsurance: NSDecimalNumber = 0
//    var adjustFixedRateMonths: Int = 0
//    var adjustInitialCap: NSDecimalNumber = 0
//    var adjustPeriodicCap: NSDecimalNumber = 0
//    var adjustLifetimeCap: NSDecimalNumber = 0
//    var adjustIntervalMonths: Int = 12
//    var startDate = Date()
//    var totalLoanCost: NSDecimalNumber = 0
//    var paymentSchedule = [Amortization]()
//    var originalMortgage: Mortgage? = nil
//    var numberOfPayments: Int = 360
//    var monthlyPayment: NSDecimalNumber = 0
//    
//    func clone() -> Mortgage {
//        let m = Mortgage()
//        m.loanTermMonths = self.loanTermMonths
//        m.salePrice = self.salePrice
//        m.interestRate = self.interestRate
//        m.downPayment = self.downPayment
//        m.extras = self.extras
//        m.propertyTaxRate = self.propertyTaxRate
//        m.homeInsurance = self.homeInsurance
//        m.adjustFixedRateMonths = self.adjustFixedRateMonths
//        m.adjustInitialCap = self.adjustInitialCap
//        m.adjustPeriodicCap = self.adjustPeriodicCap
//        m.adjustLifetimeCap = self.adjustLifetimeCap
//        m.adjustIntervalMonths = self.adjustIntervalMonths
//        m.startDate = self.startDate
//        m.totalLoanCost = self.totalLoanCost
//        m.paymentSchedule = self.paymentSchedule
//        m.originalMortgage = self.originalMortgage
//        m.numberOfPayments = self.numberOfPayments
//        m.monthlyPayment = self.monthlyPayment
//        
//        return m
//    }
//    
//    func loanAmount() -> NSDecimalNumber {
//        var str = self.downPayment
//        let i = str.characters.index(of: "%")!
//        let downPercent = NSDecimalNumber(string: str.substring(to: i))
//        let loanAmount = self.salePrice.subtracting(self.salePrice.multiplying(by: downPercent.dividing(by: 100)))
//        return loanAmount
//    }
//    
//    func totalInterestSavings() -> NSDecimalNumber {
//        setOriginalPaymentSchedule()
//        return originalMortgage!.totalLoanCost.subtracting(self.totalLoanCost)
//    }
//    
//    func interestSavedForRange(start: Int, end: Int) -> NSDecimalNumber {
//        var interestSaved7Years = NSDecimalNumber(value: 0.0)
//        for i in start..<end {
//            interestSaved7Years = interestSaved7Years.adding(self.paymentSchedule[i].interestSaved)
//        }
//        return interestSaved7Years
//    }
//    
//    func monthsSaved() -> Int {
//        return self.originalMortgage!.numberOfPayments - self.numberOfPayments
//    }
//    
//    // TODO: Bake this into the original amortization calculation
//    func setOriginalPaymentSchedule() {
//        if originalMortgage != nil {
//            // originalMortgage has already been set
//            return
//        } else {
//            // originalMortgage has not yet been set
//            if extras.isEmpty {
//                self.originalMortgage = self.clone()
//            } else {
//                var m = self.clone()
//                m.extras = []
//                m.originalMortgage = m  // Must be set to non-nil value (reference to itself, in this case) so as to no loop infinitely
//                let mc = MortgageCalculator()
//                m = mc.calculateMortgage(mortgage: m)
//                self.originalMortgage = m
//            }
//        }
//    }
//    
//    // TODO: Bake this into the original amortization calculation
//    func calculateAdditionalMetrics() {
//        for amortization in paymentSchedule {
//            calculateRemainingLoanCostForPeriod(amortization: amortization)
//            calculateInterestSavedForPeriod(amortization: amortization)
//        }
//    }
//    
//    private func calculateRemainingLoanCostForPeriod(amortization: Amortization) {
//        var remainingLoanCost = self.totalLoanCost.subtracting(amortization.interestToDate)
//        let compResult: ComparisonResult = remainingLoanCost.compare(NSDecimalNumber(value: 0))
//        
//        if compResult == ComparisonResult.orderedAscending {
//            remainingLoanCost = 0
//        }
//        
//        amortization.remainingLoanCost = remainingLoanCost
//    }
//    
//    private func calculateInterestSavedForPeriod(amortization: Amortization) {
//        if !paymentSchedule.isEmpty && !originalMortgage!.paymentSchedule.isEmpty {
//            let periodIndex = amortization.loanMonth - 1
//            let originalInterest = originalMortgage!.paymentSchedule[periodIndex].interest
//            let currentInterest = paymentSchedule[periodIndex].interest
//            amortization.interestSaved = originalInterest.subtracting(currentInterest)
//        }
//    }
//}

