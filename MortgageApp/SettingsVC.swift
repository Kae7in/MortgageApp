//
//  SettingsVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/18/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func logoutButton(_ sender: UIButton) {
        // Logout of Firebase
        try! FIRAuth.auth()?.signOut()  // TODO: Add failure catch
        
        // Manually transition back to login view
        let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUp")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        UIView.transition(with: appDelegate.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            appDelegate.window!.rootViewController = rootViewController
        }) { (completed) in
            
        }
    }
    
}
