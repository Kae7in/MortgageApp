//
//  FormError.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/6/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation

enum FormError: Error {
    case invalidType(field: String)
    case invalidLength(_: Int, field: String)
    case invalidText(field: String)
    case outOfRangeDouble(_: Double, field: String)
    case outOfRangeInt(_: Int, field: String)
    case outOfRangeDate(field: String)
}
