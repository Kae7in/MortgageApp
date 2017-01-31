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
