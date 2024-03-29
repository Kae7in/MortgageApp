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
    
    var userAccount: UserAccount?
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

        let arguments = CommandLine.arguments
        if arguments.contains("fill-registration") {
            usernameField.text = UUID().uuidString
            passwordField.text = "test123"
            confirmPasswordField.text = passwordField.text
            textFieldEditingChanged()
        }
        
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
        
        // Dismiss keyboard
        view.endEditing(true)

        assert(userAccount != nil, "A user account should be defined here")
        userAccount?.username = usernameField.text!

        let password: String = passwordField.text!
        
        // Attempt to create new Firebase User
        FIRAuth.auth()?.createUser(withEmail: (userAccount?.email)!, password: password, completion: { (user, error) in
            if user != nil {
                
                // Add additional fields for this user
                let userRef = self.ref.child(UserAccount.usersField).child(user!.uid)
                userRef.child(UserAccount.emailField).setValue(self.userAccount?.email)
                userRef.child(UserAccount.firstNameField).setValue(self.userAccount?.firstName)
                userRef.child(UserAccount.lastNameField).setValue(self.userAccount?.lastName)
                userRef.child(UserAccount.phoneField).setValue(self.userAccount?.phone)
                userRef.child(UserAccount.usernameField).setValue(self.userAccount?.username)
                userRef.child(UserAccount.timestampField).setValue(FIRServerValue.timestamp())

                self.showCreateMortgage()
            } else if error != nil {
                let controller = UIAlertController(title: NSLocalizedString("Error", comment: "Generic error"), message: error?.localizedDescription ?? NSLocalizedString("Unknown error", comment: "An unknown error occurred"), preferredStyle: UIAlertControllerStyle.alert)
                controller.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    controller.dismiss(animated: true, completion: nil)
                }))                
                self.present(controller, animated: true, completion: {})
            }
        })
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        }
        
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
        let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        UIView.transition(with: appDelegate.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: { 
            appDelegate.window!.rootViewController = rootViewController
        }) { (completed) in
            let storyboard = UIStoryboard.init(name: "CreateMortgage", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "CreateMortgage") as! UINavigationController
            let controller = navController.topViewController as! CreateMortgageFVC
            controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            controller.goingToIntro = true
            rootViewController.present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}
