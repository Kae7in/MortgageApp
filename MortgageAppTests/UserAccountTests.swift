//
//  UserAccountTests.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/1/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import XCTest
@testable import MortgageApp

class UserAccountTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSerialization() {
        let account = UserAccount(userID: "1234", firstName: "John", lastName: "Appleseed", email: "john@example.com", phone: "512-555-5555", username: "japple", creationDate: "tody")
        let dictionary = account.dict
        let serializedAccount = UserAccount(dict: dictionary)
        
        XCTAssertEqual(account, serializedAccount)
    }
}
