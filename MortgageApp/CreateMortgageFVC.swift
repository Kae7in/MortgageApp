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
    
    var mortgage = Mortgage()
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data
    var editingMortgage = false
    
    let mortgageFieldTitle = "Mortgage Name"
    let salePriceFieldTitle = "Sale Price"
    let downPaymentFieldTitle = "Down Payment"
    let loanTermFieldTitle = "Loan Term (years)"
    let interestRateFieldTitle = "Interest Rate"
    let startDateFieldTitle = "Start Date"
    let homeInsuranceFieldTitle = "Home Insurance (monthly)"
    let propertyTaxRateFieldTitle = "Property Tax Rate"
    let extraPaymentFieldTitle = "Extra Payment"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arguments = CommandLine.arguments
        if arguments.contains("fill-mortgage") {
            // Assign data to mortgage instance properties
            mortgage.name = "Willow Way"
            mortgage.salePrice = 200_000
            mortgage.interestRate = 2.38
            mortgage.startDate = Date()
            mortgage.loanTermMonths = 360
            mortgage.downPayment = 20_000
            mortgage.homeInsurance = 200
            mortgage.propertyTaxRate = 2.38
            
            editingMortgage = true
        }
        
        self.layoutNavigationBar()
        self.layoutForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.layoutForm() // Refresh after adding extra payments
    }
    
    func layoutNavigationBar() {
        self.title = "New Mortgage"
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = doneItem
    }
    
    func layoutForm() {
        self.form = Section("Basics"){ section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { 20 }
            section.header = header
            }
            <<< SegmentedRow<String>("segments") {
                $0.options = ["Fixed Rate", "Adjustable Rate"]
                $0.value = "Fixed Rate"
                $0.baseCell.backgroundColor = UIColor.clear
            }
            +++ Section("BASICS")
            <<< TextRow(){ row in
                row.title = mortgageFieldTitle
                row.placeholder = "1207 S Washington"
                row.tag = MortgageFormValidator.mortgageNameField
                row.value = editingMortgage ? mortgage.name : nil
            }
            <<< DecimalRow(){
                $0.title = salePriceFieldTitle
                $0.placeholder = "$200,000"
                $0.tag = MortgageFormValidator.salePriceField
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                $0.value = editingMortgage ? mortgage.salePrice as Double? : nil
            }
            <<< DecimalRow() {
                $0.title = downPaymentFieldTitle
                $0.placeholder = "$20,000"
                $0.tag = MortgageFormValidator.downPaymentField
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                $0.value = editingMortgage ? mortgage.downPayment.doubleValue : nil
            }
            <<< IntRow() {
                $0.title = loanTermFieldTitle
                $0.placeholder = "30"
                $0.tag = MortgageFormValidator.loanTermYearsField
                $0.value = editingMortgage ? mortgage.getLoanTermYears() : nil
            }
            <<< DecimalRow() {
                $0.title = interestRateFieldTitle
                $0.placeholder = "3.6%"
                $0.tag = MortgageFormValidator.interestRateField
                $0.value = editingMortgage ? mortgage.interestRate as Double? : nil
            }
            <<< DateRow() {
                $0.title = startDateFieldTitle
                $0.value = editingMortgage ? mortgage.startDate : Date()
                $0.tag = MortgageFormValidator.startDateField
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
                $0.title = homeInsuranceFieldTitle
                $0.placeholder = "$100"
                $0.tag = MortgageFormValidator.homeInsuranceCostField
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                $0.value = editingMortgage ? mortgage.homeInsurance as Double? : nil
            }
            <<< DecimalRow() {
                $0.title = propertyTaxRateFieldTitle
                $0.placeholder = "2.38%"
                $0.tag = MortgageFormValidator.propertyTaxRateField
                $0.value = editingMortgage ? mortgage.propertyTaxRate as Double? : nil
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
                $0.tag = "additional_payment_history"
                for extra in self.mortgage.extras {
                    $0 <<< LabelRow() { row in
                        row.title = extraPaymentFieldTitle
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US")
                        dateFormatter.setLocalizedDateFormatFromTemplate("dd/M/yyyy")
                        
                        if let endDate = extra["endDate"] as? Date {
                            // Recurring payments have an "end" date
                            row.value = dateFormatter.string(from: endDate)
                        } else if let startDate = extra["startDate"] as? Date {
                            // Both fixed and recurring payments have a "start" date
                            row.value = dateFormatter.string(from: startDate)
                        }
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
    
    func displayAlertFor(fieldName: String) {
        
        var titlesDictionary = [
            MortgageFormValidator.mortgageNameField : mortgageFieldTitle,
            MortgageFormValidator.salePriceField : salePriceFieldTitle,
            MortgageFormValidator.downPaymentField : downPaymentFieldTitle,
            MortgageFormValidator.loanTermYearsField : loanTermFieldTitle,
            MortgageFormValidator.interestRateField : interestRateFieldTitle,
            MortgageFormValidator.startDateField : startDateFieldTitle,
            MortgageFormValidator.homeInsuranceCostField : homeInsuranceFieldTitle,
            MortgageFormValidator.propertyTaxRateField : propertyTaxRateFieldTitle
        ]
        
        if let fieldTitle = titlesDictionary[fieldName] {
            let message = "\(fieldTitle) is invalid"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func validInput() -> Bool {
        var result = false
        var fieldName = ""
        let formFields = self.form.values()
        
        do {
            try MortgageFormValidator.validateFormFields(dictionary: formFields)
            result = true
        } catch FormError.invalidType(let field) {
            fieldName = field
            print("Invalid type in field \(field)")
        } catch FormError.invalidLength(let length, let field) {
            fieldName = field
            print("Invalid length in field \(field) needs \(length)")
        } catch FormError.invalidText(let field) {
            fieldName = field
            print("Invalid text in field \(field)")
        } catch FormError.outOfRangeDouble(let value, let field) {
            fieldName = field
            print("Invalid range in field \(field) needs \(value)")
        } catch FormError.outOfRangeInt(let value, let field) {
            fieldName = field
            print("Invalid range in field \(field) needs \(value)")
        } catch FormError.outOfRangeDate(let field) {
            fieldName = field
            print("Invalidate date in field \(field)")
        } catch {
            // TODO: Review lengthy post describing how to correct the error with "swift enclosing catch is not exhaustive"
            // All enum types are handled.  Adding an empty 'catch' for now.
            // http://stackoverflow.com/questions/30720497/swift-do-try-catch-syntax
        }
        
        if !MortgageFormValidator.validateExtraPayments(mortgage: self.mortgage, newStartDate: formFields[MortgageFormValidator.startDateField] as! Date) {
            let message = "Extra payments fall outside of start date"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            
            return false
        }
        
        if !result {
            displayAlertFor(fieldName: fieldName)
        }
        
        return result
    }
    
    func createAndSaveMortgage() -> Mortgage {
        
        extractMortgageProperties(mortgage: &mortgage)
        
        // Save mortgage to server
        mortgage.save()
        
        return mortgage
    }
    
    private func extractMortgageProperties(mortgage: inout Mortgage) {
        // Extract data from form
        let valuesDictionary = self.form.values()
        let name = valuesDictionary[MortgageFormValidator.mortgageNameField] as! String
        let principal = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.salePriceField] as! Double)
        let downPayment = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.downPaymentField] as! Double)
        let loanTermYears = valuesDictionary[MortgageFormValidator.loanTermYearsField] as! Int
        let interestRate = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.interestRateField] as! Double)
        let startDate = valuesDictionary[MortgageFormValidator.startDateField] as! Date
        let homeInsuranceCost = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.homeInsuranceCostField] as! Double)
        let propertyTaxRate = NSDecimalNumber(value: valuesDictionary[MortgageFormValidator.propertyTaxRateField] as! Double)
        
        // Assign data to mortgage instance properties
        mortgage.name = name
        mortgage.salePrice = principal
        mortgage.interestRate = interestRate
        mortgage.startDate = startDate
        mortgage.setLoanTerm(years: loanTermYears)
        mortgage.downPayment = downPayment
        mortgage.homeInsurance = homeInsuranceCost
        mortgage.propertyTaxRate = propertyTaxRate
    }
    
    private func showPreviousExtraPayments() {
        
        guard validInput() else {
            return
        }

        // We need to store the current mortgage values so that they persist.
        // Otherwise, when the table refreshes the user data disappears.
        // Ideally, we should refresh only a portion of the table.
        editingMortgage = true // form will display contents of mortgage object
        extractMortgageProperties(mortgage: &mortgage)
        
        let storyboard = UIStoryboard.init(name: "PreviousExtraPayments", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PreviousExtraPaymentsVC") as! PreviousExtraPaymentsVC
        mortgage.startDate = self.form.rowBy(tag: MortgageFormValidator.startDateField)?.baseValue as! Date  // TODO: Why are we modifying the mortgate object here and now?
        controller.mortgage = self.mortgage
        self.present(controller, animated: true) {}
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            // This is the extra payments section
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (mortgage.extras.indices.contains(indexPath.row)) {
            mortgage.extras.remove(at: indexPath.row)
        }
        
        layoutForm()
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
