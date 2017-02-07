//
//  PreviousExtraPaymentsFormValidatorTests.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/6/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import XCTest

class PreviousExtraPaymentsFormValidatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicData() {
        
        let dictionary : [String : Any] = [
            PreviousExtraPaymentsFormValidator.startDateField : Date(),
            PreviousExtraPaymentsFormValidator.paymentTypeField : PaymentType.recurring.rawValue,
            PreviousExtraPaymentsFormValidator.paymentAmountField : 100.00,
            PreviousExtraPaymentsFormValidator.paymentFrequencyField : 12,
            PreviousExtraPaymentsFormValidator.endDateField : Date().addingTimeInterval(1.0) // Insure end date is greater than start date
        ]
        
        do {
            try PreviousExtraPaymentsFormValidator.validateFormFields(dictionary: dictionary)
        } catch FormError.invalidType(let field) {
            XCTFail("Invalid type in field \(field)")
        } catch FormError.invalidLength(let length, let field) {
            XCTFail("Invalid length in field \(field) needs \(length)")
        } catch FormError.invalidText(let field) {
            XCTFail("Invalid text in field \(field)")
        } catch FormError.outOfRangeDouble(let value, let field) {
            XCTFail("Invalid range in field \(field) needs \(value)")
        } catch FormError.outOfRangeInt(let value, let field) {
            XCTFail("Invalid range in field \(field) needs \(value)")
        } catch FormError.outOfRangeDate(let field) {
            XCTFail("Invalidate date in field \(field)")
        } catch {
            XCTFail("Unknown failure case")
        }
    }
}
