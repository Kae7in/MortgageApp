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
    
    /// Name of this mortgage which is used in Firebase and for identifying local notifications related to this mortgage
    var name: String = ""
    
    /// Number of months the loan originated with (e.g. 30 year mortgage --> 360 months)
    var loanTermMonths: Int = 360

    /// Beginning principal amount of the loan minus the down payment; does not change
    var salePrice: NSDecimalNumber = 200000
    
    /// Interest rate (not APR) of the loan; can fluctuate in an Adjustable Rate Mortgage
    var interestRate: NSDecimalNumber = 3.6
    
    /// Percent of the mortgage principal that the downpayment makes up
    var downPayment: String = "20%"
    
    /**
     List of extra payments
     extra payment dictionary structure: ["startMonth": 1,
                                           "endMonth": 360,
                                           "extraIntervalMonths": 1,
                                           "extraAmount": 100,
                                           "unique_id": "f83jSeiqogHJDKsow295Jd"]
     
     NOTE: The unique_id property is placed in the dictionary automatically
     when 'save()' is called.
     */
    var extras: [Dictionary<String,Any>] = []
    
    /// Annual roperty tax rate (ex. .01973 == 1.973%)
    var propertyTaxRate: NSDecimalNumber = 0
    
    /// Monthly home insurance amount
    var homeInsurance: NSDecimalNumber = 0
    
    /// Number of months from start the rate will not adjust (e.g. 6 means no adjustment will happen until month 7)
    var adjustFixedRateMonths: Int = 0
    
    /// The highest adjustment possible on the first rate reset (ex. .25)
    var adjustInitialCap: NSDecimalNumber = 0
    
    /// The highest adjustment possible in any given period
    var adjustPeriodicCap: NSDecimalNumber = 0
    
    /// The highest adjustment possible over the lifetime of the loan
    var adjustLifetimeCap: NSDecimalNumber = 0
    
    /// The interval with which an adjustment reset repeats
    var adjustIntervalMonths: Int = 12
    
    /// Start date (MM/DD/YYYY)/first monthly payment of the mortgage
    var startDate = Date()
    
    /// Total amount of interest this loan cost, adjusted based on planned extra payments
    var totalLoanCost: NSDecimalNumber = 0
    
    /// Payment deteails for each period over the entire lifetime of the mortgage
    var paymentSchedule = [Amortization]()
    
    /// A copy of this mortgage instance without extra payments, for ease of comparison purposes
    var originalMortgage: Mortgage? = nil
    
    /// Number of payments that must be made until the loan is paid off (decreases when extra payments are made)
    var numberOfPayments: Int = 360
    
    /// The standard monthly payment (not including any extra payments)
    var monthlyPayment: NSDecimalNumber = -1
    
    
    /// Explicit default constructor redefinition required when creating a copy constructor
    override init() {
        super.init()
    }
    
    
    /// Copy constructor
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
    
    /// Update loan term based on years
    func setLoanTerm(years: Int) {
        self.loanTermMonths = years * 12  // TODO: Can we extract the # of months in a year from NSCalender?
    }
    
    /// Updates the down payment
    func update(downPayment: NSDecimalNumber, principal: NSDecimalNumber) {
        
        // TODO: Define magic number 100
        let downPercent = downPayment.dividing(by: principal).multiplying(by: NSDecimalNumber(value: 100))
        self.downPayment = downPercent.stringValue + "%" // TODO: Formatting should be contained in a view model class
    }
    
    /// The sale price of the loan minus the down payment
    func loanAmount() -> NSDecimalNumber {
        var str: String = self.downPayment
        let i = str.characters.index(of: "%")!
        let downPercent: NSDecimalNumber = NSDecimalNumber(string: str.substring(to: i))
        
        // self.salePrice - (down payment)
        let loanAmount = self.salePrice.subtracting(self.salePrice.multiplying(by: downPercent.dividing(by: 100)))
        
        return loanAmount
    }
    
    
    /// Total amount of interest saved due to extra payments made over the entire life of the loan
    func totalInterestSavings() -> NSDecimalNumber {
        setOriginalPaymentSchedule()  // Load up self.originalMortgage to make savings comparisons easier
        let result = originalMortgage!.totalLoanCost.subtracting(self.totalLoanCost)
        
        if result.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedAscending {
            print("ERROR: Negative savings")
            return NSDecimalNumber(value: 0)
        }
        
        return result
    }
    
    
    /// Total amount of interest saved due to extra payments over the specified range of periods [start: inclusive, end: exclusive)
    func interestSavedForRange(start: Int, end: Int) -> NSDecimalNumber {
        var totalInterestSaved = NSDecimalNumber(value: 0.0)
        
        for i in start..<end {
            totalInterestSaved = totalInterestSaved.adding(self.paymentSchedule[i].interestSaved)
        }
        
        return totalInterestSaved
    }
    
    
    /// Total amount of periods/months saved due to extra payments made over the entire life of the loan
    func monthsSaved() -> Int {
        return self.originalMortgage!.numberOfPayments - self.numberOfPayments
    }
    
    
    // TODO: Bake this into the original amortization calculation
    /// Helper used by MortgageCalculator to initialize self.originalMortgage
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
    
    
    // TODO: Bake this, and it's helpers, into the original amortization calculation
    /// Helper used by MortgageCalculator to calculate additional information for each Amortization object
    func calculateAdditionalMetrics() {
        for amortization in paymentSchedule {
            calculateRemainingLoanCostForPeriod(amortization: amortization)
            calculateInterestSavedForPeriod(amortization: amortization)
            calculateTotalInterestSavedUpToPeriod(amortization: amortization)  // This call MUST come after calculateInterestSavedForPeriod() call
        }
    }
    
    
    /// Period-calculation helper used by calculateAdditionalMetrics()
    /// ; remaining interest to be paid in the given period/month (Amortization)
    private func calculateRemainingLoanCostForPeriod(amortization: Amortization) {
        var remainingLoanCost = self.totalLoanCost.subtracting(amortization.interestToDate)
        let compResult: ComparisonResult = remainingLoanCost.compare(NSDecimalNumber(value: 0))
            
        if compResult == ComparisonResult.orderedAscending {
            remainingLoanCost = 0
        }
            
        amortization.remainingLoanCost = remainingLoanCost
    }
    
    
    /// Period-calculation helper used by calculateAdditionalMetrics()
    /// ; interest saved just this period/month (Amortization)
    private func calculateInterestSavedForPeriod(amortization: Amortization) {
        if !paymentSchedule.isEmpty && !originalMortgage!.paymentSchedule.isEmpty {
            let periodIndex = amortization.loanMonth - 1
            let originalInterest = originalMortgage!.paymentSchedule[periodIndex].interest
            let currentInterest = paymentSchedule[periodIndex].interest
            amortization.interestSaved = originalInterest.subtracting(currentInterest)
        }
    }
    
    
    /// Period-calculation helper used by calculateAdditionalMetrics()
    /// ; total interest saved up up to this period/month (Amortization)
    private func calculateTotalInterestSavedUpToPeriod(amortization: Amortization) {
        if !paymentSchedule.isEmpty && !originalMortgage!.paymentSchedule.isEmpty {
            let periodIndex = amortization.loanMonth - 1
            if periodIndex > 0 {
                amortization.interestSavedToDate = amortization.interestSaved.adding(self.paymentSchedule[periodIndex-1].interestSavedToDate)
            } else {
                amortization.interestSavedToDate = amortization.interestSaved
            }
        }
    }
    
    
    /// Returns the period/month for this mortgage given a date
    private func periodForDate(date: Date) -> Int {
        let today: Date = Date()
        let period = today.months(from: self.startDate) + 1
        
        if period > 360 {
            // date is after mortgage payoff
            return 360
        } else if period < 0 {
            // date is before self.startDate
            return 0
        } else {
            return period
        }
    }
    
    
    /// Returns the period/month for this mortgage for today's date
    func currentPeriod() -> Int {
        return self.periodForDate(date: Date())
    }
    
    
    /// Commits this Mortgage instance to the Firebase database
    func save() {
        // If this is the first time this mortgage has been saved,
        // run it through the calculator because otherwise the monthly payment
        // won't be there.
        // TODO: THIS IS HACKY. FIX THIS.
        if self.monthlyPayment.compare(NSDecimalNumber(value: 0)) == ComparisonResult.orderedAscending {
            let mc = MortgageCalculator()
            _ = mc.calculateMortgage(mortgage: self)
        }
        
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
