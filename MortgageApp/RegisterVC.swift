//
//  RegisterVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/30/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ref = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        let email: String = emailField.text!
        let username: String = usernameField.text!.lowercased()
        let password: String = passwordField.text!
        let confirmPassword: String = confirmPasswordField.text!
        
        if validateCredentialsFormat(email: email, username: username, password: password, confirmPassword: confirmPassword) {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if user != nil {
                    // Associate username with uuid
                    self.ref.child("usernames").child(username).setValue(user!.uid)
                    
                    // Associate uuid with email and username
                    let userRef = self.ref.child("users").child(user!.uid)
                    userRef.child("email").setValue(email)
                    userRef.child("username").setValue(username)
                    
                    self.performSegue(withIdentifier: "toCreateMortgage", sender: nil)
                } else if error != nil {
                    // TODO: Do something
                }
            })
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toCreateMortgage" {
            let createVC = segue.destination as! CreateMortgageVC
            createVC.goingToIntro = true
        }
    }
    
    
    func validateCredentialsFormat(email: String, username: String, password: String, confirmPassword: String) -> Bool {
        if email == "" || username == "" || password == "" { return false }
        if password != confirmPassword { return false }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
