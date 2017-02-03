//
//  MortgageFormValidator.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/3/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

enum MortgageFormError: Error {
    case invalidType(field: String)
    case invalidLength(_: Int, field: String)
    case invalidText(field: String)
    case outOfRangeDouble(_: Double, field: String)
    case outOfRangeInt(_: Int, field: String)
    case outOfRangeDate(field: String)
}

class MortgageFormValidator {

    // Form fields
    static let mortgageNameField = "mortgage_name"
    static let salePriceField = "sale_price"
    static let downPaymentField = "down_payment"
    static let loanTermYearsField = "loan_term"
    static let interestRateField = "interest_rate"
    static let startDateField = "start_date"
    static let homeInsuranceCostField = "home_insurance"
    static let propertyTaxRateField = "property_tax"
    static let additionalPaymentHistoryField = "additional_payment_history"
    
    // Validation
    static let maximumNameLength = 256
    static let maximumPrincipal = 100_000_000.00
    static let maximumloanTermYears = 40
    static let maximumInterestRate = 30.0 // TODO: What's a reasonable value here?
    static let maximumHomeInsuranceCost = 100_000_000.00 // TODO: What's a reasonable value here?
    static let maximumPropertyTaxRate = 30.0 // TODO: What's a reasonable value here?
    
    static func validateFormFields(dictionary : [String: Any?]) throws {
        
        // Name must be of type String
        guard let name = dictionary[MortgageFormValidator.mortgageNameField] as? String else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.mortgageNameField)
        }
        // Name must be ASCII only
        let range = name.rangeOfCharacter(from: NSCharacterSet.letters)
        guard range != nil else {
            throw MortgageFormError.invalidText(field: MortgageFormValidator.mortgageNameField)
        }
        // Name length must be in range
        let length = name.utf16.count
        guard (length > 0 && length < MortgageFormValidator.maximumNameLength) else {
            throw MortgageFormError.invalidLength(length, field: MortgageFormValidator.mortgageNameField)
        }
        
        // Principal must be of type Double
        guard let principal = dictionary[MortgageFormValidator.salePriceField] as? Double else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.salePriceField)
        }
        // Principal must be in range
        guard (principal > 0 && principal < MortgageFormValidator.maximumPrincipal) else {
            throw MortgageFormError.outOfRangeDouble(MortgageFormValidator.maximumPrincipal, field: MortgageFormValidator.salePriceField)
        }
        
        // Down payment must be of type Double
        guard let downPayment = dictionary[MortgageFormValidator.downPaymentField] as? Double else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.downPaymentField)
        }
        // Down payment must be in range
        guard (downPayment >= 0 && downPayment < principal) else {
            throw MortgageFormError.outOfRangeDouble(downPayment, field: MortgageFormValidator.downPaymentField)
        }
        
        // Loan term must be of type Int
        guard let loanTermYears = dictionary[MortgageFormValidator.loanTermYearsField] as? Int else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.loanTermYearsField)
        }
        guard (loanTermYears > 0 && loanTermYears < MortgageFormValidator.maximumloanTermYears) else {
            throw MortgageFormError.outOfRangeInt(loanTermYears, field: MortgageFormValidator.loanTermYearsField)
        }
        
        // Interest rate must be of type Double
        guard let interestRate = dictionary[MortgageFormValidator.interestRateField] as? Double else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.interestRateField)
        }
        // Interest rate must be in range
        guard (interestRate >= 0 && interestRate < MortgageFormValidator.maximumInterestRate) else {
            throw MortgageFormError.outOfRangeDouble(MortgageFormValidator.maximumInterestRate, field: MortgageFormValidator.interestRateField)
        }

        // Start date must be of type Date
        guard let startDate = dictionary[MortgageFormValidator.startDateField] as? Date else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.startDateField)
        }
        
        // Home insurance must be of type Double
        guard let homeInsuranceCost = dictionary[MortgageFormValidator.homeInsuranceCostField] as? Double else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.homeInsuranceCostField)
        }
        // Home insurance must be in range
        guard (homeInsuranceCost > 0 && homeInsuranceCost < MortgageFormValidator.maximumHomeInsuranceCost) else {
            throw MortgageFormError.outOfRangeDouble(MortgageFormValidator.maximumHomeInsuranceCost, field: MortgageFormValidator.homeInsuranceCostField)
        }
        
        // Property tax rate must be of type Double
        guard let propertyTaxRate = dictionary[MortgageFormValidator.propertyTaxRateField] as? Double else {
            throw MortgageFormError.invalidType(field: MortgageFormValidator.propertyTaxRateField)
        }
        // Property tax rate must be in range
        guard (propertyTaxRate >= 0 && propertyTaxRate < MortgageFormValidator.maximumPropertyTaxRate) else {
            throw MortgageFormError.outOfRangeDouble(MortgageFormValidator.maximumPropertyTaxRate, field: MortgageFormValidator.propertyTaxRateField)
        }
        
        // Project loan term must be greater than the current date
        guard MortgageFormValidator.valid(loanTermYears: loanTermYears, startDate: startDate) else {
            throw MortgageFormError.outOfRangeDate(field: MortgageFormValidator.startDateField)
        }
        
        // TODO:
        // Also need to handle situation where user creates extra payments then changes the mortgage start date such that the extra payment no longer falls within the mortgage.
    }
    
    static func valid(loanTermYears: Int, startDate: Date) -> Bool {
        let currentDate = NSDate() as Date
        let projectedDate = NSCalendar.current.date(byAdding: Calendar.Component.month, value: loanTermYears, to: startDate)
        return currentDate < projectedDate! // TODO: Assuming we get a valid value back
    }
}
