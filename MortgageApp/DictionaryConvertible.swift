//
//  DictionaryConvertible.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/1/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

protocol DictionaryConvertible {
    init?(dict:[String:AnyObject])
    var dict:[String:AnyObject] { get }
}
