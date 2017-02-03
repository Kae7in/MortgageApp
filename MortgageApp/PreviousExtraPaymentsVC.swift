//
//  PreviousExtraPaymentsVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/18/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka

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
            <<< SegmentedRow<String>("segments") {
                $0.options = ["One Time", "Recurring"]
                $0.value = "One Time"
            }
            +++ Section(header: "You must accurately add extra payments you’ve made in the past in order to correctly track the progress of your mortgage.", footer: "")
            +++ Section(header: "Extra Payment", footer: "Please provide EXACT dates and amounts.")
            <<< IntRow(){
                $0.title = "Payment Amount"
                $0.tag = "payment_amount"
                $0.placeholder = "$150"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DateRow() {
                $0.title = "Payment Date"
                $0.tag = "start_date"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< DateRow() {
                $0.title = "Payment End Date"
                $0.tag = "end_date"
                $0.hidden = "$segments != 'Recurring'"
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< IntRow() {
                $0.title = "Month-Frequency of Payments"
                $0.tag = "month_frequency"
                $0.hidden = "$segments != 'Recurring'"
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
        return true
    }
    
    
    func packageUpExtraPayment() {
        let valuesDictionary = self.form.values()
        let paymentStartDate: Date? = valuesDictionary["start_date"] as? Date
        let paymentType: String? = valuesDictionary["segments"] as? String
        let paymentAmount: Int? = valuesDictionary["payment_amount"] as? Int
        let paymentStartPeriod: Int = Calendar.current.dateComponents([.month], from: self.mortgage.startDate, to: paymentStartDate!).month! + 1
        
        var extra = ["startMonth": paymentStartPeriod, "endMonth": paymentStartPeriod, "extraIntervalMonths": 1, "extraAmount": paymentAmount!]
        
        if paymentType == "Recurring" {
            let paymentEndDate: Date? = valuesDictionary["end_date"] as? Date
            let paymentEndPeriod: Int = Calendar.current.dateComponents([.month], from: self.mortgage.startDate, to: paymentEndDate!).month! + 1
            let monthFrequency: Int? = valuesDictionary["month_frequency"] as? Int
            
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
