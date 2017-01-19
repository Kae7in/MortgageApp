//
//  CreateExtraPaymentFVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/18/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka

class CreateExtraPaymentFVC: FormViewController {
    
    var mortgage: Mortgage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutForm()
    }
    
    
    func layoutForm() {
        self.form = Section()
            <<< SegmentedRow<String>("segments") {
                $0.options = ["One Time", "Recurring"]
                $0.value = "One Time"
            }
            +++ Section(header: "Extra Payments", footer: "Please provide EXACT dates and amounts.")
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
            <<< ButtonRow("Done.") { (row: ButtonRow) in
                row.title = row.tag
            }
            .onCellSelection({ (cell, row) in
                self.packageUpExtraPayment()
                self.dismiss(animated: true, completion: {})
            })
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

}
