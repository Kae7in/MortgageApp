//  CreateMortgageVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth


class CreateMortgageVC: UIViewController {

    @IBOutlet weak var principal: UITextField!
    @IBOutlet weak var apr: UITextField!
    @IBOutlet weak var termYears: UITextField!
    @IBOutlet weak var downPercent: UITextField!
    
    var goingToIntro: Bool = false
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        try! FIRAuth.auth()?.signOut()
        let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UIView.transition(with: appDelegate.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            appDelegate.window!.rootViewController = rootViewController
        }) { (completed) in
            
        }
    }
    
    @IBAction func mortgageSubmitted(_ sender: UIButton) {
        if validateInput() {
            let m = Mortgage()
            m.salePrice = NSDecimalNumber(value: Double(self.principal.text!)!)
            m.interestRate = NSDecimalNumber(value: Double(self.apr.text!)!)
            m.loanTermMonths = Int(self.termYears.text!)! * 12
            m.downPayment = self.downPercent.text! + "%"
            
            if self.goingToIntro {
                performSegue(withIdentifier: "toIntro", sender: nil)
            } else {
                self.mortgageData.mortgages.append(m)
                
                self.dismiss(animated: true, completion: {
                })
            }
        }
    }
    
    func validateInput() -> Bool {
        if principal.text!.isEmpty
            || apr.text!.isEmpty
            || termYears.text!.isEmpty
            || downPercent.text!.isEmpty
        {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toIntro" {
            let introPVC = segue.destination as! IntroPVC
            introPVC.mortgage = self.mortgageData.mortgages.last!
            self.goingToIntro = false
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
}

