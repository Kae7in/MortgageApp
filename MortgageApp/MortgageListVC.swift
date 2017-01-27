//
//  MortgageListVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/2/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MortgageListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var mortgageData = MortgageData()
    var ref: FIRDatabaseReference!
    // TODO: Add refresh

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
        loadMortgages()
        layoutViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    
    /* Perform required view setup before the view appears */
    func layoutViews() {
        // Navigation bar layout
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 238, green: 87, blue: 106, alpha: 1.0)
        self.navigationItem.title = "Mortgages"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 18.0)!, NSForegroundColorAttributeName: UIColor.black]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addMortgage))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
        
        // Set tableview cell class
        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    /* Load mortgages from Firebase db to be placed in tableview */
    func loadMortgages() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        let mortgage_ref = self.ref.child("mortgages").child(userID!)
        let query = mortgage_ref.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            
            let list_of_mortgages = snapshot.value as? NSDictionary
            for (_, mortgage_dict) in list_of_mortgages! {
                let dict = mortgage_dict as! NSDictionary
                
                // Use data to create local Mortgage object
                let mortgage = Mortgage()
                
                mortgage.name = dict["name"] as! String
                mortgage.salePrice = NSDecimalNumber(decimal: (dict["salePrice"] as! NSNumber).decimalValue)
                mortgage.interestRate = NSDecimalNumber(decimal: (dict["interestRate"] as! NSNumber).decimalValue)
                mortgage.downPayment = dict["downPayment"] as! String
                mortgage.propertyTaxRate = NSDecimalNumber(decimal: (dict["propertyTaxRate"] as! NSNumber).decimalValue)
                mortgage.homeInsurance = NSDecimalNumber(decimal: (dict["homeInsurance"] as! NSNumber).decimalValue)
                mortgage.adjustFixedRateMonths = Int(dict["adjustFixedRateMonths"] as! Int)
                mortgage.adjustInitialCap = NSDecimalNumber(decimal: (dict["adjustInitialCap"] as! NSNumber).decimalValue)
                mortgage.adjustPeriodicCap = NSDecimalNumber(decimal: (dict["adjustPeriodicCap"] as! NSNumber).decimalValue)
                mortgage.adjustLifetimeCap = NSDecimalNumber(decimal: (dict["adjustLifetimeCap"] as! NSNumber).decimalValue)
                mortgage.adjustIntervalMonths = Int(dict["adjustIntervalMonths"] as! Int)
                mortgage.totalLoanCost = NSDecimalNumber(decimal: (dict["totalLoanCost"] as! NSNumber).decimalValue)
                mortgage.numberOfPayments = Int(dict["numberOfPayments"] as! Int)
                mortgage.monthlyPayment = NSDecimalNumber(decimal: (dict["monthlyPayment"] as! NSNumber).decimalValue)
                
                // Set date
                let dateString = dict["startDate"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                mortgage.startDate = dateFormatter.date(from: dateString)!

                // Set extra payments, if any
                if let extras_dict = dict["extraPayments"] {
                    let extras = extras_dict as! NSDictionary
                    for (_, value) in extras {
                        let extra = value as! Dictionary<String, Any>
                        mortgage.extras.append(extra)
                    }
                }
                
                // Append mortgage to local data cache
                self.mortgageData.mortgages.append(mortgage)
            }
            self.tableView.reloadData()
        })
    }
    
    
    /* Target of rightBarButtomItem (add button for creating a new morgage) */
    func addMortgage() {
        performSegue(withIdentifier: "toCreateMortgage", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toCreateMortgage" {
            // User selected the add mortgage button
            let dest: CreateMortgageFVC = segue.destination as! CreateMortgageFVC
            dest.mortgageData = self.mortgageData
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // UITableViewDelegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mortgageData.mortgages.count
    }
    
    
    // UITableViewDataSource method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let mortgage = self.mortgageData.mortgages[indexPath.row]
        
        var string = mortgage.name
        var defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 24.0)!, NSForegroundColorAttributeName: UIColor.black]
        var attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        cell.textLabel?.attributedText = attributedString  // set cell title
        
        string = "$" + String(Int(mortgage.totalInterestSavings())) + " saved"
        defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 14.0)!, NSForegroundColorAttributeName: UIColor.init(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1)]
        attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        cell.detailTextLabel?.attributedText = attributedString  // set cell subtitle TODO: change this to mortgage balance (principal + interest)
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    
    // UITableViewDelegate method
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    // UITableViewDelegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Show mortgate detail
        let mortgage = self.mortgageData.mortgages[indexPath.row]
        let storyboard = UIStoryboard.init(name: "MortgageDetail", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MortgageDetailVC") as! MortgageDetailVC
        
        // Pass the mortgage associated with that cell to the mortgage detail view controller
        controller.mortgage = mortgage
        controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }

}


/* 
 Local Cache for passing mortgage data back from the ExtraPaymentVC to this one
 */
class MortgageData {
    // This is where all of the loaded mortgages will be stored.
    // Each cell indexpath in the tableview corresponds to an index in this array.
    var mortgages: [Mortgage] = []
}
