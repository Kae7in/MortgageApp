//
//  CreateMortgageFVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/17/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka

class CreateMortgageFVC: FormViewController {
    
    var goingToIntro: Bool = false  // This flag should be set to true if this is the first ever mortgage the user has created
    var mortgageData = MortgageData()  // List of mortgages the previous UITableView will use as data


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.form = Section("Basics")
            <<< SegmentedRow<String>("segments") { $0.options = ["Fixed Rate", "Adjustable Rate"] }
            <<< TextRow(){ row in
                row.title = "Mortgage Name"
                row.placeholder = "1207 S Washington"
            }
            <<< DecimalRow(){
                $0.title = "Sale Price"
                $0.placeholder = "$200,000"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< IntRow() {
                $0.title = "Loan Term (years)"
                $0.placeholder = "30"
            }
            <<< DecimalRow() {
                $0.title = "Interest Rate"
                $0.placeholder = "3.6%"
            }
            <<< DateRow() {
                $0.title = "Start Date"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            +++ Section("Additional Details")
            <<< DecimalRow(){
                $0.title = "Home Insurance (monthly)"
                $0.placeholder = "$100"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DecimalRow() {
                $0.title = "Property Tax Rate"
                $0.placeholder = "2.38%"
            }
            +++ Section("Adjustable Rate Details") {
                $0.hidden = "$segments != 'Adjustable Rate'"
            }
            <<< TextRow(){ row in
                row.title = "Blah"
                row.placeholder = "Blah"
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
