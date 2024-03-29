//
//  RegisterInformationVC.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/30/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit

class RegisterInformationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextButton: RoundedButton!
    @IBOutlet weak var facebookRegisterLabel: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var facebookTapGesture: UITapGestureRecognizer?
    var userAccount: UserAccount?

    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Construct facebook registration attributes
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
        facebookRegisterLabel.attributedText = attributeString
        
        // Add gesture for facebook label
        facebookTapGesture = UITapGestureRecognizer(target: self, action: #selector(facebookLabelTapped(_:)))
        facebookRegisterLabel.addGestureRecognizer(facebookTapGesture!)
        
        addDoneButtonOnKeyboard()
        hideKeyboardWhenTappedAround()
        
        // Disable next button until fields are valid
        nextButton.enable(enabled: false)
        
        // Add field validation to enable/disable fields
        firstNameField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        lastNameField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        
        // Fill form with fake data for easier testing
        let arguments = CommandLine.arguments
        if arguments.contains("fill-registration") {
            firstNameField.text = "FirstName"
            lastNameField.text = "LastName"
            let uuid = UUID().uuidString
            emailField.text = String(format: "%@@example.com", uuid)
            textFieldEditingChanged()
        }

        super.viewDidLoad()
    }
    
    deinit {
        facebookRegisterLabel.removeGestureRecognizer(facebookTapGesture!)
    }
    
    // MARK: Actions
    @IBAction func nextButtonTouchDown(_ sender: Any) {
        nextButton.highlight()
    }
    
    @IBAction func nextButtonTouchUpInside(_ sender: Any) {
        nextButton.removeHighlight()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSignIn" {
            //let controller = segue.destination as! LoginVC
            // TODO: pass email through
        } else if segue.identifier == "toRegisterCredentials" {
            let controller = segue.destination as! RegisterCredentialsVC
            
            if userAccount == nil {
                // Create a new account object since once does not exist yet
                userAccount = UserAccount(firstName: firstNameField.text!, lastName: lastNameField.text!, email: emailField.text!, phone: phoneTextField.text!)
            } else {
                // Update properties as they may have been modified
                userAccount?.firstName = firstNameField.text!
                userAccount?.lastName = lastNameField.text!
                userAccount?.email = emailField.text!
                userAccount?.phone = phoneTextField.text!
            }
            
            // Pass the user account through for further processing
            controller.userAccount = userAccount

            controller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        }
    }

    // MARK: Gestures
    func facebookLabelTapped(_ gesture: UIGestureRecognizer) {
        print("tap")
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            phoneTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldEditingChanged() {
        
        var valid = emailField.text?.isValidEmail()
        
        if (!(firstNameField.text?.isValidUsername())!) {
            valid = false
        }
        
        if (!(lastNameField.text?.isValidUsername())!) {
            valid = false
        }
        
        // Bypassing validation of phone #s since they could vary significantly.

        nextButton.enable(enabled: valid!)
    }
    
    // MARK: Helpers
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector
            (doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        phoneTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        phoneTextField.resignFirstResponder()
    }
    
}
