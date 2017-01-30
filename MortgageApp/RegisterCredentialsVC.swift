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

class RegisterCredentialsVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
        self.hideKeyboardWhenTappedAround()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if validateFields() {
            let email: String = emailField.text!
            let username: String = usernameField.text!.lowercased()
            let password: String = passwordField.text!
            
            // Attempt to create new Firebase User
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
    }
        
    /* Validate the login fields (e.g. fields not empty) */
    func validateFields() -> Bool {
        let email: String = emailField.text!
        let username: String = usernameField.text!.lowercased()
        let password: String = passwordField.text!
        let confirmPassword: String = confirmPasswordField.text!
        
        if email == "" || username == "" || password == "" || confirmPassword == "" { return false }
        if password != confirmPassword { return false }
        
        return true
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
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        // Segue to the sign in screen
        let controller = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "signIn")
        controller.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.present(controller, animated: true) {
        }
    }
    
}
