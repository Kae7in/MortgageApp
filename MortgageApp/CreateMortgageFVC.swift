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

class CreateMortgageFVC: UITableViewController {

    let mortgage = Mortgage()
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var FBRef: FIRDatabaseReference!
    
    enum RateType: String {
        case fixed = "Fixed Rate"
        case adjustable = "Adjustable Rate"
    }
    
    var sectionTitles = ["", "BASICS", "ADDITIONAL DETAILS", "PREVIOUS EXTRA PAYMENTS"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.FBRef = FIRDatabase.database().reference()
        self.layoutNavigationBar()
        
        // Hide separators for the first cell which contains a segment
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.customGrey()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
    }
    
    func layoutNavigationBar() {

        self.title = "New Mortgage"
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(done))
        self.navigationItem.leftBarButtonItem = cancelItem
        self.navigationItem.rightBarButtonItem = doneItem
    }
    
//    func layoutForm() {
//        self.form = Section("Basics"){ section in
//            var header = HeaderFooterView<UIView>(.class)
//            header.height = { self.navBar.frame.height }
//            section.header = header
//            }
//            <<< SegmentedRow<String>("segments") {
//                $0.options = ["Fixed Rate", "Adjustable Rate"]
//                $0.value = "Fixed Rate"
//            }
//            +++ Section("BASICS")
//            <<< TextRow(){
//                $0.title = "Mortgage Name"
//                $0.placeholder = "1207 S Washington"
//                $0.tag = MortgageFormValidator.mortgageNameField
//                $0.add(rule: RuleRequired())
//                $0.add(rule: RuleRegExp(regExpr: "^[ -~]+$", allowsEmpty: false)) // ASCII only
//                $0.add(rule: RuleMaxLength(maxLength: UInt(MortgageFormValidator.maximumNameLength)))
//                $0.validationOptions = .validatesOnChange
//                }.cellUpdate { cell, row in
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//                }
//                .onRowValidationChanged({ (cell, row) in
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//                })
//            <<< DecimalRow(){
//                $0.title = "Sale Price"
//                $0.placeholder = "$200,000"
//                $0.tag = MortgageFormValidator.salePriceField
//                let formatter = CurrencyFormatter()
//                formatter.locale = .current
//                formatter.numberStyle = .currency
//                $0.formatter = formatter
//                //$0.add(rule: RuleRequired())
//                //$0.add(rule: RuleGreaterThan(min: 0))
//                //$0.add(rule: RuleSmallerThan(max: MortgageFormValidator.maximumPrincipal))
//                $0.validationOptions = .validatesOnChange
//                }.cellUpdate { cell, row in
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//                }
//                .onRowValidationChanged({ (cell, row) in
//                    if !row.isValid {
//                        cell.titleLabel?.textColor = .red
//                    }
//                })
//            <<< DecimalRow() {
//                $0.title = "Down Payment"
//                $0.placeholder = "$20,000"
//                $0.tag = MortgageFormValidator.downPaymentField
//                let formatter = CurrencyFormatter()
//                formatter.locale = .current
//                formatter.numberStyle = .currency
//                $0.formatter = formatter
//            }
//            <<< IntRow() {
//                $0.title = "Loan Term (years)"
//                $0.placeholder = "30"
//                $0.tag = MortgageFormValidator.loanTermYearsField
//            }
//            <<< DecimalRow() {
//                $0.title = "Interest Rate"
//                $0.placeholder = "3.6%"
//                $0.tag = MortgageFormValidator.interestRateField
//            }
//            <<< DateRow() {
//                $0.title = "Start Date"
//                $0.value = Date()
//                $0.tag = MortgageFormValidator.startDateField
//                let formatter = DateFormatter()
//                formatter.locale = .current
//                formatter.dateStyle = .short
//                $0.dateFormatter = formatter
//                }
//                .onChange({ (row) in
//                    // TODO: Update all extra payments (if any) to reflect this change
//                })
//            +++ Section("ADDITIONAL DETAILS")
//            <<< DecimalRow(){
//                $0.title = "Home Insurance (monthly)"
//                $0.placeholder = "$100"
//                $0.tag = MortgageFormValidator.homeInsuranceCostField
//                let formatter = CurrencyFormatter()
//                formatter.locale = .current
//                formatter.numberStyle = .currency
//                $0.formatter = formatter
//            }
//            <<< DecimalRow() {
//                $0.title = "Property Tax Rate"
//                $0.placeholder = "2.38%"
//                $0.tag = MortgageFormValidator.propertyTaxRateField
//            }
//            +++ Section("Adjustable Rate Details") {
//                $0.hidden = "$segments != 'Adjustable Rate'"
//            }
//            // TODO: Add ARM related fields
//            <<< TextRow(){ row in
//                row.title = "Blah"
//                row.placeholder = "Blah"
//            }
//            +++ Section("PREVIOUS EXTRA PAYMENTS"){
//                $0.tag = "additional_payment_history"
//                for extra in self.mortgage.extras {
//                    $0 <<< LabelRow() { row in
//                        row.title = "Extra Payment"
//                        
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.locale = Locale(identifier: "en_US")
//                        dateFormatter.setLocalizedDateFormatFromTemplate("dd/M/yyyy")
//                        
//                        if let endDate = extra["endDate"] as? Date {
//                            // Recurring payments have an "end" date
//                            row.value = dateFormatter.string(from: endDate)
//                        } else if let startDate = extra["startDate"] as? Date {
//                            // Both fixed and recurring payments have a "start" date
//                            row.value = dateFormatter.string(from: startDate)
//                        }
//                    }
//                }
//        }
//        form.last! <<< CustomButtonRow() { row in
//            row.value = ButtonData(title: "Add Extra Payment", action: ClosureSleeve({
//                self.showPreviousExtraPayments()
//            }))
//            }
//            .onCellSelection({ (cell, row) in
//                self.showPreviousExtraPayments()
//            })
//    }
    
    
    func done() {
//        if validInput() {
//            let m = createAndSaveMortgage()
//            UNNotificationRequest.setPaymentReminderNotification(mortgage: m)
//            
//            // Save to local cache that the previous view can access
//            self.mortgageData.mortgages.append(m)
//            
//            
//            // if this is the first ever mortgage the user has created
//            if self.goingToIntro {
//                let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "IntroPVC") as! IntroPVC
//                controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//                controller.mortgage = self.mortgageData.mortgages.last!
//                self.goingToIntro = false
//                self.present(controller, animated: true) {
//                }
//            } else {
//                self.dismiss(animated: true, completion: {
//                })
//            }
//        }
    }
    
    
    func cancel() {
        self.dismiss(animated: true, completion: {})
    }
    
    func showAlertForField(_ title: String?) {
        let message = "\(title) is invalid"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
//    func validInput() -> Bool {
//        var result = false
//        var fieldName = ""
//        
//        self.form.validate()
//        return false
//        
//        do {
//            try MortgageFormValidator.validateFormFields(dictionary: self.form.values())
//            result = true
//        } catch FormError.invalidType(let field) {
//            fieldName = field
//            print("Invalid type in field \(field)")
//        } catch FormError.invalidLength(let length, let field) {
//            fieldName = field
//            print("Invalid length in field \(field) needs \(length)")
//        } catch FormError.invalidText(let field) {
//            fieldName = field
//            print("Invalid text in field \(field)")
//        } catch FormError.outOfRangeDouble(let value, let field) {
//            fieldName = field
//            print("Invalid range in field \(field) needs \(value)")
//        } catch FormError.outOfRangeInt(let value, let field) {
//            fieldName = field
//            print("Invalid range in field \(field) needs \(value)")
//        } catch FormError.outOfRangeDate(let field) {
//            fieldName = field
//            print("Invalidate date in field \(field)")
//        } catch {
//            // TODO: Review lengthy post describing how to correct the error with "swift enclosing catch is not exhaustive"
//            // All enum types are handled.  Adding an empty 'catch' for now.
//            // http://stackoverflow.com/questions/30720497/swift-do-try-catch-syntax
//        }
//        
//        if !result {
//            let index = IndexPath(row: 0, section: 1)
//            let cell = self.tableView?.cellForRow(at: index)
//            let title = cell?.textLabel?.text ?? "?"
//            let message = "\(title) is invalid"
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
//                alert.dismiss(animated: true, completion: nil)
//            }))
//            present(alert, animated: true, completion: {
//            })
//        }
//        return result
//    }
    
    func createAndSaveMortgage() -> Mortgage {
        
        // TODO: Do we want to instantiate the mortage object here?  mortgage = Mortgage()
        // Perhaps not in case there are extra payments already entered?
        
        // Verify we are validating data first
//        assert(validInput())
        
//        // Extract data from form
//        let valuesDictionary = self.form.values()
//        let name = valuesDictionary[MortgageFormValidator.mortgageNameField] as! String
//        let principal = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.salePriceField] as! Double)
//        let downPayment = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.downPaymentField] as! Double)
//        let loanTermYears = valuesDictionary[MortgageFormValidator.loanTermYearsField] as! Int
//        let interestRate = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.interestRateField] as! Double)
//        let startDate = valuesDictionary[MortgageFormValidator.startDateField] as! Date
//        let homeInsuranceCost = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.homeInsuranceCostField] as! Double)
//        let propertyTaxRate = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.propertyTaxRateField] as! Double)
//        
//        // Assign data to mortgage instance properties
//        mortgage.name = name
//        mortgage.salePrice = principal
//        mortgage.interestRate = interestRate
//        mortgage.startDate = startDate
//        mortgage.setLoanTerm(years: loanTermYears)
//        mortgage.update(downPayment: downPayment, principal: principal)
//        mortgage.homeInsurance = homeInsuranceCost
//        mortgage.propertyTaxRate = propertyTaxRate
//        
//        self.mortgage.save()
        
        return mortgage
    }
    
    private func showPreviousExtraPayments() {
//        let storyboard = UIStoryboard.init(name: "PreviousExtraPayments", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "PreviousExtraPaymentsVC") as! PreviousExtraPaymentsVC
//        self.mortgage.startDate = self.form.rowBy(tag: MortgageFormValidator.startDateField)?.baseValue as! Date  // TODO: Why are we modifying the mortgate object here and now?
//        controller.mortgage = self.mortgage
//        self.present(controller, animated: true) {
//        }
    }

    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if indexPath.section == 0 {
            // MORTAGE TYPE
            let typeCell = tableView.dequeueReusableCell(withIdentifier: "MortgageTypeCell") as! MortgageTypeCell
            cell = typeCell
        } else if indexPath.section == 1 {
            // BASICS
            
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "MortgageDetailCell") as! MortgageDetailCell
            detailCell.fieldLabel.text = "FIELD"
            detailCell.textField.text = "DATA"
            
            cell = detailCell
            
        } else if indexPath.section == 2 {
            // ADDITIONAL DETAILS
        } else {
            // PREVIOUS EXTRA PAYMENTS
        }
        
        return cell!
    }

    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            // This is the extra payments section
            return true
        }
        
        return false
    }

    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if mortgage.extras.indices.contains(indexPath.row) {
            mortgage.extras.remove(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Heights are based on design
        if section == 0 {
            return 12.0
        }
        
        return 22.0
    }
    
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            cell.backgroundColor = UIColor.clear
//        }
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
}


// TODO: Evaluate
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
