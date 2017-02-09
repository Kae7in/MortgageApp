//
//  PreviousExtraPaymentsVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/18/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka

// TODO: This enum should be moved to the future "ExtraPayment" class
enum PaymentType: String {
    case oneTime = "One Time"
    case recurring = "Recurring"
}

class PreviousExtraPaymentsVC: FormViewController {
    
    var mortgage: Mortgage!
    var navBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutNavigationBar()
        layoutForm()
    }
    
    
    func layoutNavigationBar() {
        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height + 44))
        navBar.isTranslucent = true
        self.view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Previous Extra Payment")
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
        self.form = Section(){ section in
                var header = HeaderFooterView<UIView>(.class)
                header.height = { self.navBar.frame.height }
                section.header = header
            }
            <<< SegmentedRow<String>(PreviousExtraPaymentsFormValidator.paymentTypeField) {
                $0.options = [PaymentType.oneTime.rawValue, PaymentType.recurring.rawValue]
                $0.value = PaymentType.oneTime.rawValue
            }
            +++ Section(header: "You must accurately add extra payments you’ve made in the past in order to correctly track the progress of your mortgage.", footer: "")
            +++ Section(header: "Extra Payment", footer: "Please provide EXACT dates and amounts.")
            <<< DecimalRow(){
                $0.title = "Payment Amount"
                $0.tag = PreviousExtraPaymentsFormValidator.paymentAmountField
                $0.placeholder = "$150.00"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DateRow() {
                $0.title = "Payment Date"
                $0.tag = PreviousExtraPaymentsFormValidator.startDateField
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< DateRow() {
                $0.title = "Payment End Date"
                $0.tag = "end_date"
                $0.hidden = "$payment_type != 'Recurring'" // TODO: How can we substitute string literal definitions matching each string here?
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< IntRow() {
                $0.title = "Month-Frequency of Payments"
                $0.tag = PreviousExtraPaymentsFormValidator.paymentFrequencyField
                $0.hidden = "$payment_type != 'Recurring'" // TODO: How can we substitute string literal definitions matching each string here?
                $0.value = 1
            }
    }
    
    
    func done() {
        if validInput() {
            self.packageUpExtraPayment()
            self.dismiss(animated: true, completion: {})
        }
    }
    
    
    func cancel() {
        self.dismiss(animated: true, completion: {})
    }
    
    
    func validInput() -> Bool {
        var result = false
        var fieldName = ""

        do {
            try PreviousExtraPaymentsFormValidator.validateFormFields(dictionary: self.form.values())
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

        if !result {
            let message = "Contents of field \(fieldName) is invalid"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: {
            })
        }
        
        return result
    }
    
    
    func packageUpExtraPayment() {
        let valuesDictionary = self.form.values()
        let paymentStartDate = valuesDictionary[PreviousExtraPaymentsFormValidator.startDateField] as? Date
        let paymentType = valuesDictionary[PreviousExtraPaymentsFormValidator.paymentTypeField] as? String
        let paymentAmount = valuesDictionary[PreviousExtraPaymentsFormValidator.paymentAmountField] as? Double
        let paymentStartPeriod = Calendar.current.dateComponents([.month], from: self.mortgage.startDate, to: paymentStartDate!).month! + 1
        
        // We store/access the extra amount as an integer
        let integerPayment = Int(paymentAmount!)
        
        var extra = ["startMonth": paymentStartPeriod, "endMonth": paymentStartPeriod, "extraIntervalMonths": 1, "extraAmount": integerPayment] as [String : Any]
        extra["startDate"] = paymentStartDate
        
        if paymentType == PaymentType.recurring.rawValue {
            let paymentEndDate: Date? = valuesDictionary[PreviousExtraPaymentsFormValidator.endDateField] as? Date
            let paymentEndPeriod: Int = Calendar.current.dateComponents([.month], from: self.mortgage.startDate, to: paymentEndDate!).month! + 1
            let monthFrequency: Int? = valuesDictionary[PreviousExtraPaymentsFormValidator.paymentFrequencyField] as? Int
            
            extra["endDate"] = paymentEndDate
            extra["endMonth"] = paymentEndPeriod
            extra["extraIntervalMonths"] = monthFrequency
        }
        
        self.mortgage.extras.append(extra)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.backgroundColor = UIColor.clear
            // TODO: Attempting to remove the line seperator for this cell only.
            // This is something that may need to be done when the cell is created.
            cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        }
    }
}
