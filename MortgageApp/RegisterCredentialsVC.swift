//
//  RegisterCredentialsVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/30/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterCredentialsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createAccountButton: RoundedButton!
    
    
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        
        // Setup back button
        let string = NSLocalizedString("< Back", comment: "Back button to take user to previous screen")
        let attributeString = NSMutableAttributedString(string: string, attributes:
            [
                NSForegroundColorAttributeName : UIColor.black,
                NSFontAttributeName : UIFont.systemFont(ofSize: 18)
            ]
        )
        let range = NSRange(location: 0, length: 1)
        attributeString.addAttribute(NSFontAttributeName, value:UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold), range: range)
        backButton .setAttributedTitle(attributeString, for: UIControlState.normal)
        backButton.alpha = 0
        
        // Disable next button until fields are valid
        createAccountButton.enable(enabled: false)
        
        // Add field validation to enable/disable fields
        usernameField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)

        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fade back button in
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backButton.alpha = 1.0
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func createAccountButtonTouchDown(_ sender: Any) {
        createAccountButton.highlight()
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        createAccountButton.removeHighlight()
        
        // TODO: Pass to Firebase
        
        let username: String = usernameField.text!.lowercased()
        let password: String = passwordField.text!
        
        // Attempt to create new Firebase User
        let email = "example@example.com"
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if user != nil {
                // Associate username with uuid
                self.ref.child("usernames").child(username).setValue(user!.uid)
                
                // Add fields to uuid entry
                let userRef = self.ref.child("users").child(user!.uid)
                userRef.child("email").setValue(email)
                userRef.child("username").setValue(username)
                
                self.showCreateMortgage()
            } else if error != nil {
                // TODO: Implement proper error response
            }
        })
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.becomeFirstResponder()
        print(#function)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldEditingChanged() {
        
        var valid = usernameField.text?.isValidUsername()
        let password = passwordField.text!
        let confirmPassword = confirmPasswordField.text!
        
        if (!password.isValidPassword()) {
            valid = false
        }

        if (!confirmPassword.isValidPassword()) {
            valid = false
        }
        
        if password != confirmPassword {
            valid = false
        }
        
        createAccountButton.enable(enabled: valid!)
    }
    
    private func showCreateMortgage() {
        let storyboard = UIStoryboard.init(name: "CreateMortgage", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateMortgageFVC") as! CreateMortgageFVC
        controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        controller.goingToIntro = true
        let navController = UINavigationController.init(rootViewController: controller)
        self.present(navController, animated: true) {
        }
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}
