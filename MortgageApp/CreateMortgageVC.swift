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
    
    var goingToIntro: Bool = false
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
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
            let m = createAndSaveMortgage()
            
            self.mortgageData.mortgages.append(m)
            
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
        // Create Mortgage instance
        let m = Mortgage()
        m.name = self.name.text!
        m.salePrice = NSDecimalNumber(value: Double(self.principal.text!)!)
        m.interestRate = NSDecimalNumber(value: Double(self.apr.text!)!)
        m.loanTermMonths = Int(self.termYears.text!)! * 12
        m.downPayment = self.downPercent.text! + "%"
        
        // Get current user
        let user = FIRAuth.auth()?.currentUser!
        
        // Get user's mortgages list
        let ref = self.ref.child("mortgages/\(user!.uid)").child(m.name)
        
        // Create reflection of mortgage object
        let mirrored_object = Mirror(reflecting: m)
        
        // Skip these attributes
        let attributes_not_allowed: [String] = ["extras", "paymentSchedule", "originalMortgage", "startDate"]
        
        // Save the mortgage object's necessary attributes
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                if attributes_not_allowed.contains(property_name) { continue }
                
                ref.child(property_name).setValue(attr.value)
            }
        }
        
        // Add date attribute
        let dateF = DateFormatter()
        dateF.dateFormat = "MMMM dd yyyy"
        let str = dateF.string(from: m.startDate)
        ref.child("startDate").setValue(str)
        
        // TODO: Add extras attribute
        
        return m
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

