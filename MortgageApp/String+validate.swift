//
//  String+validate.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/31/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }
}
