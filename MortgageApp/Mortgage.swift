//
//  Mortgage.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Mortgage: NSObject {
    var name: String = ""
    var loanTermMonths: Int = 360
    var salePrice: NSDecimalNumber = 200000
    var interestRate: NSDecimalNumber = 3.6
    var downPayment: String = "20%"
    var extras: [Dictionary<String,Any>] = []
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
        self.name = mortgage.name
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
        let result = originalMortgage!.totalLoanCost.subtracting(self.totalLoanCost)
        
        if result.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedAscending {
            return NSDecimalNumber(value: 0)
        }
        
        return result
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
    
    func save() {
        let ref = FIRDatabase.database().reference()
        
        // Get current user
        let user = FIRAuth.auth()?.currentUser!
        
        // Get user's mortgages list
        let mortgages_ref = ref.child("mortgages/\(user!.uid)").child(self.name)
        
        // Create reflection of mortgage object
        let mirrored_object = Mirror(reflecting: self)
        
        // Skip these attributes (extras will be processed outside of this loop
        let attributes_not_allowed: [String] = ["extras", "paymentSchedule", "originalMortgage", "startDate"]
        
        // Save the mortgage object's necessary attributes
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                if attributes_not_allowed.contains(property_name) { continue }
                
                mortgages_ref.child(property_name).setValue(attr.value)
            }
        }
        
        // Add date attribute
        let dateF = DateFormatter()
        dateF.dateFormat = "MMMM dd yyyy"
        let str = dateF.string(from: self.startDate)
        mortgages_ref.child("startDate").setValue(str)
        
        // Add extra payments, if any
        for extra in self.extras {
            var extra_ref = ref.child("mortgages").child(user!.uid).child(self.name).child("extraPayments")
            
            if let unique_id = extra["unique_id"] {
                let uid = unique_id as! String
                extra_ref.child(uid).setValue(extra)
            } else {
                // This is a new extra! Give it a unique_id
                extra_ref = extra_ref.childByAutoId()
                extra_ref.child("unique_id").setValue(extra_ref.key)
                extra_ref.child("startMonth").setValue(extra["startMonth"] as! Int)
                extra_ref.child("endMonth").setValue(extra["endMonth"] as! Int)
                extra_ref.child("extraIntervalMonths").setValue(extra["extraIntervalMonths"] as! Int)
                extra_ref.child("extraAmount").setValue(extra["extraAmount"] as! Int)
            }
        }
    }
    
}
