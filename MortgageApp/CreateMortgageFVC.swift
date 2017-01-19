//
//  CreateMortgageFVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/17/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka
import FirebaseDatabase

class CreateMortgageFVC: FormViewController {
    
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var ref: FIRDatabaseReference!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        layoutForm()
    }
    
    
    func layoutForm() {
        self.form = Section("Basics")
            <<< SegmentedRow<String>("segments") {
                $0.options = ["Fixed Rate", "Adjustable Rate"]
                $0.value = "Fixed Rate"
            }
            <<< TextRow(){ row in
                row.title = "Mortgage Name"
                row.placeholder = "1207 S Washington"
                row.tag = "mortgage_name"
            }
            <<< DecimalRow(){
                $0.title = "Sale Price"
                $0.placeholder = "$200,000"
                $0.tag = "sale_price"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DecimalRow() {
                $0.title = "Down Payment"
                $0.placeholder = "$20,000"
                $0.tag = "down_payment"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< IntRow() {
                $0.title = "Loan Term (years)"
                $0.placeholder = "30"
                $0.tag = "loan_term"
            }
            <<< DecimalRow() {
                $0.title = "Interest Rate"
                $0.placeholder = "3.6%"
                $0.tag = "interest_rate"
            }
            <<< DateRow() {
                $0.title = "Start Date"
                $0.value = Date()
                $0.tag = "start_date"
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            +++ Section("Additional Details")
            <<< DecimalRow(){
                $0.title = "Home Insurance (monthly)"
                $0.placeholder = "$100"
                $0.tag = "home_insurance"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DecimalRow() {
                $0.title = "Property Tax Rate"
                $0.placeholder = "2.38%"
                $0.tag = "property_tax"
            }
            +++ Section("Adjustable Rate Details") {
                $0.hidden = "$segments != 'Adjustable Rate'"
            }
            // TODO: Add ARM related fields
            <<< TextRow(){ row in
                row.title = "Blah"
                row.placeholder = "Blah"
            }
            +++ Section("Additional Payment History")
            <<< ButtonRow("Add Extra Payment") { (row: ButtonRow) in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "toCreateExtraPayment", onDismiss: nil)
            }
            +++ Section()
            <<< ButtonRow("Done.") { (row: ButtonRow) in
                row.title = row.tag
                // row.presentationMode = .segueName(segueName: "RowsExampleViewControllerSegue", onDismiss: nil)
            }
            .onCellSelection({ (cell, row) in
                self.done()
            })
    }
    
    
    func done() {
        if validInput() {
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
    
    
    func validInput() -> Bool {
        let valuesDictionary = self.form.values()
        let name: String? = valuesDictionary["mortgage_name"] as? String
        let principal: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["sale_price"] as! Double)
        let downPayment: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["down_payment"] as! Double)
        let loanTerm: Int? = valuesDictionary["loan_term"] as? Int
        let interestRate: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["interest_rate"] as! Double)
        let startDate: Date? = valuesDictionary["start_date"] as? Date
        
        // TODO: Validate these values
        
        return true
    }
    
    
    func createAndSaveMortgage() -> Mortgage {
        let valuesDictionary = self.form.values()
        let name: String? = valuesDictionary["mortgage_name"] as? String
        let principal: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["sale_price"] as! Double)
        let downPayment: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["down_payment"] as! Double)
        let loanTerm: Int? = valuesDictionary["loan_term"] as? Int
        let interestRate: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["interest_rate"] as! Double)
        let startDate: Date? = valuesDictionary["start_date"] as? Date
        
        // Create Mortgage instance
        let m = Mortgage()
        m.name = name!
        m.salePrice = principal!
        m.interestRate = interestRate!
        m.loanTermMonths = loanTerm! * 12
        let downPercent: NSDecimalNumber? = downPayment?.dividing(by: principal!).multiplying(by: NSDecimalNumber(value: 100))
        m.downPayment = downPercent!.stringValue + "%"
        m.startDate = startDate!
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}



class CurrencyFormatter : NumberFormatter, FormatterProtocol {
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
        guard obj != nil else { return }
        let str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
    }
    
    
    func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
        return textInput.position(from: position, offset:((newValue?.characters.count ?? 0) - (oldValue?.characters.count ?? 0))) ?? position
    }
    
}
