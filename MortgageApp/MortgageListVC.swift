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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ref = FIRDatabase.database().reference()
        loadMortgages()
        layoutViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func layoutViews() {
        layoutNavigationBar()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    func loadMortgages() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        let mortgage_ref = self.ref.child("mortgages").child(userID!)
        let query = mortgage_ref.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            for (_, mortgage_dict) in value! {
                let dict = mortgage_dict as! NSDictionary
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
                
                // Add date
                let dateString = dict["startDate"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                mortgage.startDate = dateFormatter.date(from: dateString)!

                // TODO: Add extras
                let extras: [Dictionary<String, Int>] = []
                mortgage.extras = extras
                
                self.mortgageData.mortgages.append(mortgage)
            }
            self.tableView.reloadData()
        })
    }
    
    
    func layoutNavigationBar() {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 238, green: 87, blue: 106, alpha: 1.0)
        self.navigationItem.title = "Mortgages"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addMortgage))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
    }
    
    func addMortgage() {
        performSegue(withIdentifier: "toCreateMortgage", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toCreateMortgage" {
            let dest: CreateMortgageVC = segue.destination as! CreateMortgageVC
            dest.mortgageData = self.mortgageData
        } else if segue.identifier! == "toMortgageDetail" {
            if let cellIndexPath = sender as? IndexPath {
                let cellIndex = cellIndexPath.row
                let mortgage = self.mortgageData.mortgages[cellIndex]
                let mortgageDetailVC = segue.destination as! MortgageDetailVC
                
                mortgageDetailVC.mortgage = mortgage
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mortgageData.mortgages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let mortgage = self.mortgageData.mortgages[indexPath.row]
        
        cell.textLabel?.text = mortgage.name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMortgageDetail", sender: indexPath)
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


class MortgageData {
    var mortgages: [Mortgage] = []
}
