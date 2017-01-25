//
//  UIViewController+keyboard.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/25/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
