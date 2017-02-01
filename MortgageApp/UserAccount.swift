//
//  UserAccount.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/1/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

class UserAccount: DictionaryConvertible, Equatable {
    
    static let userIDField = "userID"
    static let firstNameField = "firstName"
    static let lastNameField = "lastName"
    static let emailField = "email"
    static let phoneField = "phone"
    static let usernameField = "username"
    static let creationDateField = "creationDate"
    
    var userID: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var username: String
    var creationDate: String

    /// Default initializer
    init(userID: String, firstName: String, lastName: String, email: String, phone: String, username: String, creationDate: String) {
        
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.username = username
        self.creationDate = creationDate
    }

    static func ==(lhs: UserAccount, rhs: UserAccount) -> Bool {
        return lhs.userID == rhs.userID &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.email == rhs.email &&
        lhs.phone == rhs.phone &&
        lhs.username == rhs.username &&
        lhs.creationDate == rhs.creationDate
    }
    
    // MARK: DictionaryConvertible protocol methods
    required convenience init?(dict:[String:AnyObject]) {
        guard let userID = dict[UserAccount.userIDField] as? String,
            let firstName = dict[UserAccount.firstNameField] as? String,
            let lastName = dict[UserAccount.lastNameField] as? String,
            let email = dict[UserAccount.emailField] as? String,
            let phone = dict[UserAccount.phoneField] as? String,
            let username = dict[UserAccount.usernameField] as? String,
            let creationDate = dict[UserAccount.creationDateField] as? String else {
                
                return nil
        }
        
        self.init(userID: userID, firstName: firstName, lastName: lastName, email: email, phone: phone, username: username, creationDate: creationDate)
    }
    
    var dict:[String:AnyObject] {
        return [
            UserAccount.userIDField: userID as AnyObject,
            UserAccount.firstNameField: firstName as AnyObject,
            UserAccount.lastNameField: lastName as AnyObject,
            UserAccount.emailField: email as AnyObject,
            UserAccount.phoneField: phone as AnyObject,
            UserAccount.usernameField: username as AnyObject,
            UserAccount.creationDateField: creationDate as AnyObject
            ]
    }
}
