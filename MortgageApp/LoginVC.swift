//
//  LoginVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/30/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: RoundedButton!
    @IBOutlet weak var facebookSignInLabel: UILabel!
    
    var facebookTapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Construct facebook registration attributes
        // TODO: This code is duplicated from RegisterInformationVC. Create an extension or custom class.
        let string = NSLocalizedString("Register with Facebook", comment: "Prompt for user to register with Faceobok")
        let attributeString = NSMutableAttributedString(string: string, attributes:
            [
                NSForegroundColorAttributeName : UIColor.textGrey(),
                NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
            ]
        )
        
        let range = NSRange(location: 14, length: 8)
        attributeString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        attributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
        facebookSignInLabel.attributedText = attributeString
        
        // Add gesture for facebook label
        facebookTapGesture = UITapGestureRecognizer(target: self, action: #selector(facebookLabelTapped(_:)))
        facebookSignInLabel.addGestureRecognizer(facebookTapGesture!)
        
        // Disable next button until fields are valid
        signInButton.enable(enabled: false)
        
        // Add field validation to enable/disable fields
        emailField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    deinit {
        facebookSignInLabel.removeGestureRecognizer(facebookTapGesture!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.becomeFirstResponder()
        print(#function)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        print(#function)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        print(#function)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        print(#function)
        return true
    }
    
    func textFieldEditingChanged() {
        
        var valid = emailField.text?.isValidEmail()
        let password = passwordField.text!
        
        if (!password.isValidPassword()) {
            valid = false
        }
        
        signInButton.enable(enabled: valid!)
    }
    
    // MARK: Actions
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        let email: String = emailField.text!
        let password: String = passwordField.text!
        
        // Attempt Firebase user sign-in
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if user != nil {
                let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window!.rootViewController = rootViewController
            } else if error != nil {
                // TODO
            }
        })
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        // navigate to the login screen
        let rootViewController: UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "signUp")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.isHidden = true
        
        appDelegate.window!.rootViewController = navigationController
    }
    
    // MARK: Gestures
    func facebookLabelTapped(_ gesture: UIGestureRecognizer) {
        print("tap")
    }
}
