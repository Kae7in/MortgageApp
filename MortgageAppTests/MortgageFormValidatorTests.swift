//
//  MortgageFormValidatorTests.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/3/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import XCTest

class MortgageFormValidatorTests: XCTestCase {
    
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
            MortgageFormValidator.mortgageNameField : "123 Somewhere Drive",
            MortgageFormValidator.salePriceField : 100000.00,
            MortgageFormValidator.downPaymentField : 1000.00,
            MortgageFormValidator.loanTermYearsField : 30,
            MortgageFormValidator.interestRateField : 5.0,
            MortgageFormValidator.startDateField : Date(),
            MortgageFormValidator.homeInsuranceCostField : 100.00,
            MortgageFormValidator.propertyTaxRateField : 8.0
        ]

        do {
            try MortgageFormValidator.validateFormFields(dictionary: dictionary)
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
