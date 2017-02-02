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
import UserNotifications

class CreateMortgageFVC: FormViewController {
    
    let mortgage = Mortgage()
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var ref: FIRDatabaseReference!
    var formHasLoadedOnce = false
    var navBar: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        self.layoutNavigationBar()
        self.layoutForm()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        if formHasLoadedOnce {
            self.layoutForm()  // TODO: Get rid of this hacky way of reloading the form when extra payment rows have been added
        }
        self.formHasLoadedOnce = true
    }
    
    
    func layoutNavigationBar() {
        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height + 44))
        navBar.isTranslucent = true
        self.view.addSubview(navBar)
        let navItem = UINavigationItem(title: "New Mortgage")
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: #selector(cancel))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(done))
        navItem.leftBarButtonItem = cancelItem
        navItem.rightBarButtonItem = doneItem
        self.navBar.setItems([navItem], animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    func layoutForm() {
        self.form = Section("Basics"){ section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { self.navBar.frame.height }
            section.header = header
            }
            <<< SegmentedRow<String>("segments") {
                $0.options = ["Fixed Rate", "Adjustable Rate"]
                $0.value = "Fixed Rate"
            }
            +++ Section("BASICS")
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
                .onChange({ (row) in
                    // TODO: Update all extra payments (if any) to reflect this change
                })
            +++ Section("ADDITIONAL DETAILS")
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
            +++ Section("PREVIOUS EXTRA PAYMENTS"){
                // TODO: Enable swipe to delete/edit actions on these rows using editActionsForRowAtIndexPath UITableViewDelegate method
                $0.tag = "additional_payment_history"
                for extra in self.mortgage.extras {
                    $0 <<< LabelRow() { row in
                        row.title = "Extra Payment"
                        row.value = String(extra["extraAmount"] as! Int)  // TODO: Show start date and/or end date instead of amount
                    }
                }
        }
        form.last! <<< CustomButtonRow() { row in
            row.value = ButtonData(title: "Add Extra Payment", action: ClosureSleeve({
                self.showPreviousExtraPayments()
            }))
            }
            .onCellSelection({ (cell, row) in
                self.showPreviousExtraPayments()
            })
    }
    
    
    func done() {
        if validInput() {
            let m = createAndSaveMortgage()
            UNNotificationRequest.setPaymentReminderNotification(mortgage: m)
            
            // Save to local cache that the previous view can access
            self.mortgageData.mortgages.append(m)
            
            
            // if this is the first ever mortgage the user has created
            if self.goingToIntro {
                let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "IntroPVC") as! IntroPVC
                controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                controller.mortgage = self.mortgageData.mortgages.last!
                self.goingToIntro = false
                self.present(controller, animated: true) {
                }
            } else {
                self.dismiss(animated: true, completion: {
                })
            }
        }
    }
    
    
    func cancel() {
        self.dismiss(animated: true, completion: {})
    }
    
    
    func validInput() -> Bool {
        // Handle unused variables
        //        let valuesDictionary = self.form.values()
        //
        //        let name: String? = valuesDictionary["mortgage_name"] as? String
        //        let principal: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["sale_price"] as! Double)
        //        let downPayment: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["down_payment"] as! Double)
        //        let loanTerm: Int? = valuesDictionary["loan_term"] as? Int
        //        let interestRate: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["interest_rate"] as! Double)
        //        let startDate: Date? = valuesDictionary["start_date"] as? Date
        //        let backItem = UIBarButtonItem()
        //        backItem.title = ""
        //        navigationItem.backBarButtonItem = backItem
        
        // TODO: Validate these values
        
        return true
    }
    
    func createAndSaveMortgage() -> Mortgage {
        // Extract data from form
        let valuesDictionary = self.form.values()
        let name: String? = valuesDictionary["mortgage_name"] as? String
        let principal: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["sale_price"] as! Double)
        let downPayment: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["down_payment"] as! Double)
        let loanTerm: Int? = valuesDictionary["loan_term"] as? Int
        let interestRate: NSDecimalNumber? = NSDecimalNumber(value: valuesDictionary["interest_rate"] as! Double)
        let startDate: Date? = valuesDictionary["start_date"] as? Date
        
        // Assign data to mortgage instance properties
        self.mortgage.name = name!
        self.mortgage.salePrice = principal!
        self.mortgage.interestRate = interestRate!
        self.mortgage.loanTermMonths = loanTerm! * 12
        let downPercent: NSDecimalNumber? = downPayment?.dividing(by: principal!).multiplying(by: NSDecimalNumber(value: 100))
        self.mortgage.downPayment = downPercent!.stringValue + "%"
        self.mortgage.startDate = startDate!
        
        self.mortgage.save()
        
        return mortgage
    }
    
    private func showPreviousExtraPayments() {
        let storyboard = UIStoryboard.init(name: "PreviousExtraPayments", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PreviousExtraPaymentsVC") as! PreviousExtraPaymentsVC
        self.mortgage.startDate = self.form.rowBy(tag: "start_date")?.baseValue as! Date  // TODO: Why are we modifying the mortgate object here and now?
        controller.mortgage = self.mortgage
        self.present(controller, animated: true) {
        }
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
