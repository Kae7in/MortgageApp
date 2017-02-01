//
//  UserAccount.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/1/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

class UserAccount {
    
    static let usersField = "users"
    static let userIDField = "userID"
    static let firstNameField = "firstName"
    static let lastNameField = "lastName"
    static let emailField = "email"
    static let phoneField = "phone"
    static let usernameField = "username"
    static let timestampField = "timestamp"
    
    private var _username = ""
    
    var userID: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var username: String {
        get {
            return _username
        }
        set {
            _username = newValue.lowercased()
        }
    }
    
    /// Default initializer
    init(firstName: String, lastName: String, email: String, phone: String = "") {
        
        self.userID = ""
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.username = ""
    }
}
