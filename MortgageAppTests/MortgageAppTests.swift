//
//  MortgageAppTests.swift
//  MortgageAppTests
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import XCTest
@testable import MortgageApp

class MortgageAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCalculateLoanAmount1() {
        let m = Mortgage()
        
        m.downPayment = "20%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        
        XCTAssert(m.loanAmount() == 160000)
    }
    
    func testCalculateLoanAmount2() {
        let m = Mortgage()
        
        m.downPayment = "0%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        
        XCTAssert(m.loanAmount() == 200000)
    }
    
    func testRoundDecimals() {
        let c = MortgageCalculator()
        
        var num: NSDecimalNumber = 10.276281
        XCTAssertEqual(c.roundDecimals(num: num), 10.28)
        
        num = 0.0128
        XCTAssertEqual(c.roundDecimals(num: num), 0.01)
        
        num = 0.0151
        XCTAssertEqual(c.roundDecimals(num: num), 0.02)
    }
    
    func testCalculateExtraPayment1() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        
        XCTAssertEqual(c.calculateExtraPayment(mortgage: m, loanMonth: 1), NSNumber(value: 0))
    }
    
    func testCalculateExtraPayment2() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.extras.append(["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":100])
        
        XCTAssertEqual(c.calculateExtraPayment(mortgage: m, loanMonth: 7), NSNumber(value: 10000))
    }
    
    func testCalculateExtraPayment3() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.extras.append(["startMonth":200, "endMonth":200, "extraIntervalMonths":1, "extraAmount":1000])
        
        XCTAssertEqual(c.calculateExtraPayment(mortgage: m, loanMonth: 200), NSNumber(value: 100000))
    }
    
    func testAprToMonthlyInterest1() {
        let c = MortgageCalculator()
        
        XCTAssertEqual(c.aprToMonthlyInterest(apr: NSDecimalNumber(value: 3.6)), 0.003)
    }
    
    func testCalculatePropertyTax1() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.propertyTaxRate = 2.10
        
        XCTAssertEqual(c.calculatePropertyTax(mortgage: m), 35000)
    }
    
    func testNeedsInterestReset() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.adjustFixedRateMonths = 24
        m.adjustIntervalMonths = 12
        
        XCTAssert(c.needsInterestReset(mortgage: m, loanMonth: 37))
    }
    
    func testCalculateInterestRate1() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.adjustFixedRateMonths = 24
        m.adjustIntervalMonths = 12
        m.adjustPeriodicCap = 0.3
        m.adjustLifetimeCap = 0.5
        
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 37), 3.9)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 49), 4.1)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 61), 4.1)
    }
    
    func testCalculateInterestRate2() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.adjustFixedRateMonths = 24
        m.adjustIntervalMonths = 12
        m.adjustPeriodicCap = 0.3
        m.adjustLifetimeCap = 1.0
        
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 37), 3.9)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 49), 4.2)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 61), 4.5)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 73), 4.6)
        XCTAssertEqual(c.calculateInterestRate(mortgage: m, loanMonth: 85), 4.6)
    }
    
    func testCalculateMonthlyPayment1() {
        let m = Mortgage()
        let c = MortgageCalculator()
        
        m.downPayment = "0%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        
        XCTAssertEqual(c.roundDecimals(num: c.calculateMonthlyPayment(loanAmount: m.loanAmount(), loanTermMonths: m.loanTermMonths, interestRate: m.interestRate)), 909.29)
    }
    
    func testExtraPayments1() {
        var m = Mortgage()
        let c = MortgageCalculator()
        
        m.downPayment = "0%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":100]]
        
        m = c.calculateMortgage(mortgage: m)
        XCTAssert(m.paymentSchedule.count == 302)
        XCTAssertEqual(m.paymentSchedule[37].remainingLoanBalance, 183551.85)
        XCTAssertEqual(m.totalLoanCost, 104109.91)
    }
    
    func testExtraPayments2() {
        var m = Mortgage()
        let c = MortgageCalculator()
        
        m.downPayment = "0%"
        m.interestRate = 3.6
        m.loanTermMonths = 360
        m.salePrice = 200000
        m.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":1, "extraAmount":100], ["startMonth":1, "endMonth":1, "extraIntervalMonths":1, "extraAmount":1000]]
        m = c.calculateMortgage(mortgage: m)
        
        XCTAssert(m.paymentSchedule.count == 299)
        XCTAssertEqual(m.paymentSchedule[100].remainingLoanBalance, 150449.88)
        XCTAssertEqual(m.totalLoanCost, 102656.41)
        XCTAssertEqual(m.paymentSchedule[100].remainingLoanCost, 49268.17)
        XCTAssertEqual(m.paymentSchedule[100].interestSaved, 38.96)
        XCTAssertEqual(m.totalInterestSavings(), 24688.31)
    }
    
    // TODO: Write ARM Mortgage tests
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
