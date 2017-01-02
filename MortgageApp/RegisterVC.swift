//
//  RegisterVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/30/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        let email: String = emailField.text!
        let password: String = passwordField.text!
        
        if validateCredentialsFormat(email: email, password: password) {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if user != nil {
                    let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstMortgage")
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController = rootViewController
                } else if error != nil {
                    // TODO: Do something
                }
            })
        }
    }
    
    
    // TODO: Implement
    func validateCredentialsFormat(email: String, password: String) -> Bool {
        let pass1 = self.passwordField.text!
        let pass2 = self.passwordField.text!
        
        return pass1 == pass2 ? true : false
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
