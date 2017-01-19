//  CreateMortgageVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/7/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class CreateMortgageVC: UIViewController {

    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var principal: UITextField!
    @IBOutlet weak var apr: UITextField!
    @IBOutlet weak var termYears: UITextField!
    @IBOutlet weak var downPercent: UITextField!
    
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func mortgageSubmitted(_ sender: UIButton) {
        if validateInput() {
            let m = createAndSaveMortgage()
            
            // Save to local cache that the previous view can access
            self.mortgageData.mortgages.append(m)
            
            // if this is the first ever mortgage the user has created
            if self.goingToIntro {
                performSegue(withIdentifier: "toIntro", sender: nil)
            } else {
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
    
    func createAndSaveMortgage() -> Mortgage {
        let principalAmount = NSDecimalNumber(value: Double(self.principal.text!)!)
        let interestRate = NSDecimalNumber(value: Double(self.apr.text!)!)
        
        // Create Mortgage instance
        let m = Mortgage()
        m.name = self.name.text!
        m.salePrice = principalAmount
        m.interestRate = interestRate
        m.loanTermMonths = Int(self.termYears.text!)! * 12
        m.downPayment = self.downPercent.text! + "%"
        
        m.save()
        
        return m
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if this is the first ever mortgage the user has created
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

