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

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutForm()
    }
    
    
    func layoutForm() {
        self.form = Section()
            +++ Section(header: "Extra Payments", footer: "Please provide EXACT dates and amounts.")
            <<< DecimalRow(){
                $0.title = "Payment Amount"
                $0.placeholder = "$150"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DateRow() {
                $0.title = "Payment Date"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< ButtonRow("Done.") { (row: ButtonRow) in
                row.title = row.tag
            }
            .onCellSelection({ (cell, row) in
                self.dismiss(animated: true, completion: {})
            })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
