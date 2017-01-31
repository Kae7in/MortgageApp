//
//  LoginVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/30/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        if validateFields() {
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
    }
    
    
    /* Validate the login fields (e.g. fields not empty) */
    func validateFields() -> Bool {
        let email: String = emailField.text!
        let password: String = passwordField.text!
        
        if email == "" || password == "" { return false }
        
        return true
    }
    
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        // navigate to the login screen
        let rootViewController: UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "signUp")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.isHidden = true
        
        appDelegate.window!.rootViewController = navigationController
    }
    
}
