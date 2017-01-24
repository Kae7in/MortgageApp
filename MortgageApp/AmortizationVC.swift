//
//  AmortizationVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/22/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit
import GlyuckDataGrid

class AmortizationVC: UIViewController, UIToolbarDelegate, DataGridViewDataSource {
    
    var mortgage: Mortgage? = nil
    var toolbar: UIToolbar!
    var segmentedControl: UISegmentedControl!
    var dataGridView: DataGridView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mc = MortgageCalculator()
        self.mortgage!.originalMortgage! = mc.calculateMortgage(mortgage: self.mortgage!.originalMortgage!)  // To populate the original mortgage's paymentSchedule
        
        self.navigationItem.title = "Amortization"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: nil, action: nil)
        layoutSegmentedControlBar()
        layoutGridView()
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
        self.toolbar.clipsToBounds = true
        self.view.addSubview(self.toolbar)
        
        self.segmentedControl = UISegmentedControl(items: ["Original", "Current", "Savings"])
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 1
        self.segmentedControl.tintColor = UIColor.primary()
        self.segmentedControl.frame = CGRect(x: self.segmentedControl.frame.minX, y: self.segmentedControl.frame.minY, width: 250.0, height: self.segmentedControl.frame.height)
        toolbar.addSubview(self.segmentedControl)

        self.segmentedControl.center = CGPoint(x: self.toolbar.bounds.midX, y: self.toolbar.bounds.midY)
        self.segmentedControl.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    }
    
    
    func layoutGridView() {
        let y = self.toolbar.frame.maxY
        let frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height - y - self.tabBarController!.tabBar.frame.height)
        
        self.dataGridView = DataGridView(frame: frame)
        self.dataGridView.dataSource = self
        self.dataGridView.rowHeaderWidth = 43.0
        self.dataGridView.columnHeaderHeight = 40.0
        self.view.addSubview(dataGridView)
    }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    
    func segmentedControlAction() {
        self.dataGridView.reloadData()
    }
    
    
    // MARK: - DataGridViewDataSource
    
    // You'll need to tell number of columns in data grid view
    func numberOfColumnsInDataGridView(_ dataGridView: DataGridView) -> Int {
        return 4
    }
    
    // And number of rows
    func numberOfRowsInDataGridView(_ dataGridView: DataGridView) -> Int {
        return self.mortgage!.loanTermMonths
    }
    
    // Row headers
    func dataGridView(_ dataGridView: DataGridView, titleForHeaderForRow row: Int) -> String {
        return String(row + 1)
    }
    
    
    // Column headers
    func dataGridView(_ dataGridView: DataGridView, titleForHeaderForColumn column: Int) -> String {
        var string = ""
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            switch column {
            case 0:
                string = "PAYMENT"
            case 1:
                string = "PRINCIPAL"
            case 2:
                string = "INTEREST"
            case 3:
                string = "BALANCE"
            default:
                string = "ERROR"
            }
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            switch column {
            case 0:
                string = "PAYMENT"
            case 1:
                string = "PRINCIPAL"
            case 2:
                string = "INTEREST"
            case 3:
                string = "BALANCE"
            default:
                string = "ERROR"
            }
        } else if self.segmentedControl.selectedSegmentIndex == 2 {
            switch column {
            case 0:
                string = "ORIGINAL INTEREST"
            case 1:
                string = "NEW INTEREST"
            case 2:
                string = "SAVED TODAY"
            case 3:
                string = "SAVED TOTAL"
            default:
                string = "ERROR"
            }
        }
        
        return string
    }
    
    
    // And for text for content cells
    func dataGridView(_ dataGridView: DataGridView, textForCellAtIndexPath indexPath: IndexPath) -> String {
        let originalPaymentScheduleCount = self.mortgage?.originalMortgage?.paymentSchedule.count
        let paymentScheduleCount = self.mortgage?.paymentSchedule.count
        let row: Int = indexPath.dataGridRow
        
        if row >= originalPaymentScheduleCount! { return "$0" }
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            if indexPath.dataGridColumn == 0 {  // (original) MONTHLY PAYMENT
                let monthlyPayment: Int? = self.mortgage?.originalMortgage?.paymentSchedule[row].scheduledMonthlyPayment.intValue
                return "$" + String(monthlyPayment!)
            } else if indexPath.dataGridColumn == 1 {  // (original) PRINCIPAL
                let principal: Int? = self.mortgage?.originalMortgage?.paymentSchedule[row].principal.intValue
                return "$" + String(principal!)
            } else if indexPath.dataGridColumn == 2 {  // (original) INTEREST
                let interest: Int? = self.mortgage?.originalMortgage?.paymentSchedule[row].interest.intValue
                return "$" + String(interest!)
            } else if indexPath.dataGridColumn == 3 {  // (original) BALANCE (P)
                let balance: Int? = self.mortgage?.originalMortgage?.paymentSchedule[row].remainingLoanBalance.intValue
                return "$" + String(balance!)
            }
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            if row >= paymentScheduleCount! { return "$0" }
            
            if indexPath.dataGridColumn == 0 {  // MONTHLY PAYMENT
                let monthlyPayment: Int? = self.mortgage?.paymentSchedule[row].scheduledMonthlyPayment.intValue
                return "$" + String(monthlyPayment!)
            } else if indexPath.dataGridColumn == 1 {  // PRINCIPAL
                let principal: Int? = self.mortgage?.paymentSchedule[row].principal.intValue
                return "$" + String(principal!)
            } else if indexPath.dataGridColumn == 2 {  // INTEREST
                let interest: Int? = self.mortgage?.paymentSchedule[row].interest.intValue
                return "$" + String(interest!)
            } else if indexPath.dataGridColumn == 3 {  // BALANCE (P)
                let balance: Int? = self.mortgage?.paymentSchedule[row].remainingLoanBalance.intValue
                return "$" + String(balance!)
            }
        } else if self.segmentedControl.selectedSegmentIndex == 2 {
            if indexPath.dataGridColumn == 0 {  // (original) INTEREST PAYMENT
                return "$" + self.mortgage!.originalMortgage!.paymentSchedule[row].interest.stringValue
            } else if indexPath.dataGridColumn == 1 {  // INTEREST PAYMENT
                if row >= paymentScheduleCount! { return "$0" }
                return "$" + self.mortgage!.paymentSchedule[row].interest.stringValue
            } else if indexPath.dataGridColumn == 2 {  // SAVED TODAY
                if row >= paymentScheduleCount! { return "$0" }
                return "$" + self.mortgage!.paymentSchedule[row].interestSaved.stringValue
            } else if indexPath.dataGridColumn == 3 {  // TOTAL SAVED
                if row >= paymentScheduleCount! {
                    return "$" + self.mortgage!.paymentSchedule[paymentScheduleCount! - 1].interestSavedToDate.stringValue
                } else {
                    return "$" + self.mortgage!.paymentSchedule[row].interestSavedToDate.stringValue
                }
            }
        }
        
        return "ERROR"
    }
}
