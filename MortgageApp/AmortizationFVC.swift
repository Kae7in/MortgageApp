//
//  AmortizationVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/22/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import Eureka

class AmortizationFVC: FormViewController, UIToolbarDelegate {
    
    var mortgage: Mortgage? = nil
    var toolbar: UIToolbar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Amortization"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: nil, action: nil)
        layoutSegmentedControlBar()
        layoutForm()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func layoutSegmentedControlBar() {
        let y = self.navigationController!.navigationBar.frame.maxY
        self.toolbar = UIToolbar(frame: CGRect(x: 0, y: y, width: self.view.frame.width, height: 40))
        self.toolbar.delegate = self
        self.toolbar.isTranslucent = false
        self.toolbar.barTintColor = UIColor.customGrey()
        self.view.addSubview(self.toolbar)
        
        let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["Original", "Current", "Savings"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.tintColor = UIColor.primary()
        toolbar.addSubview(segmentedControl)

        segmentedControl.center = CGPoint(x: self.toolbar.bounds.midX, y: self.toolbar.bounds.midY)
        segmentedControl.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    
    func layoutForm() {
        self.form = Section(){ section in
                var header = HeaderFooterView<UIView>(.class)
                let height = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height + self.toolbar.frame.height
                header.height = { height }
                section.header = header
            }
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
    }

}
