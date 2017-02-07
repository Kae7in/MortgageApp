//
//  PreviousExtraPaymentsFormValidator.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/6/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

class PreviousExtraPaymentsFormValidator {

    // Form fields
    static let startDateField = "start_date"
    static let endDateField = "end_date"
    static let paymentTypeField = "payment_type"
    static let paymentAmountField = "payment_amount"
    static let paymentFrequencyField = "month_frequency"
    
    static func validateFormFields(dictionary : [String: Any?]) throws {
        
        // Start date is required
        guard let startDate = dictionary[PreviousExtraPaymentsFormValidator.startDateField] as? Date else {
            throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.startDateField)
        }
        
        // Form restricts start date to type Date so we can ignore type validation.
        
        // Segments is required
        guard let paymentType = dictionary[PreviousExtraPaymentsFormValidator.paymentTypeField] as? String else {
            throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.paymentTypeField)
        }
        
        // Segment type must be valid
        guard (paymentType == PaymentType.oneTime.rawValue || paymentType == PaymentType.recurring.rawValue) else {
            throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.paymentTypeField)
        }
        
        // Payment amount must be of type Double
        guard let paymentAmount = dictionary[PreviousExtraPaymentsFormValidator.paymentAmountField] as? Double else {
            throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.paymentAmountField)
        }
        
        // Payment amount must be in range
        guard (paymentAmount > 0) else {
            throw FormError.outOfRangeDouble(paymentAmount, field: PreviousExtraPaymentsFormValidator.paymentAmountField)
        }

        if paymentType == PaymentType.recurring.rawValue {

            // Recurring payments must have an end date
            guard  let endDate = dictionary[PreviousExtraPaymentsFormValidator.endDateField] as? Date else {
                throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.endDateField)
            }
            
            // Require end date > start date
            guard endDate > startDate else {
                throw FormError.outOfRangeDate(field: PreviousExtraPaymentsFormValidator.endDateField)
            }
            
            // Payment frequency must be of type Int
            guard (dictionary[PreviousExtraPaymentsFormValidator.paymentFrequencyField] as? Int) != nil else {
                throw FormError.invalidType(field: PreviousExtraPaymentsFormValidator.paymentFrequencyField)
            }
        }
    }
}
