//
//  MortgageDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import Charts

class MortgageDetailVC: UIViewController {
    
    var m: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceCents: UILabel!
    @IBOutlet weak var yearsLeftLabel: UILabel!
    @IBOutlet weak var monthsLeftLabel: UILabel!
    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        m!.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":12, "extraAmount":Int(m!.monthlyPayment)]]
        m = mc.calculateMortgage(mortgage: m!)
        layoutViews()
    }
    
    func layoutViews() {
        updateLabels()
        layoutNavigationBar()
        layoutExtraPaymentButton()
        updateChartWithData()
    }
    
    func updateLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let balanceComponents = numberFormatter.string(from: m!.loanAmount().adding(m!.totalLoanCost))!.components(separatedBy: ".")
        
        balance.text! = balanceComponents.first!
        if balanceComponents.count > 1 {
            balanceCents.text! = "." + balanceComponents.last!
        } else {
            balanceCents.text! = ".00"
        }
        
        let yearsLeft = self.m!.numberOfPayments / 12
        let remainingMonthsLeft = self.m!.numberOfPayments % 12
        
        self.yearsLeftLabel.text! = String(yearsLeft) + "yr"
        self.monthsLeftLabel.text! = String(remainingMonthsLeft) + "mo"
    }
    
    func layoutNavigationBar() {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 238, green: 87, blue: 106, alpha: 1.0)
        self.navigationItem.title = "Mortgage Balance"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 200, green: 200, blue: 200, alpha: 1.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
        
        let segment:UISegmentedControl = UISegmentedControl(items: ["Total", "Principal", "Interest"])
        segment.sizeToFit()
        segment.tintColor = UIColor(rgbColorCodeRed: 238, green: 87, blue: 106, alpha: 1.0)
        segment.selectedSegmentIndex = 0
//        self.navigationItem.titleView = segment
        let f = self.navigationController!.navigationBar.frame
        segment.frame = CGRect(x: f.minX + 80.0, y: f.minY + 50.0, width: f.width - 160.0, height: 30.0)
        self.view.addSubview(segment)
    }
    
    func layoutExtraPaymentButton() {
//        extraPaymentButton.layer.borderColor = UIColor.clear.cgColor
//        extraPaymentButton.layer.borderWidth = 5.0
//        extraPaymentButton.layer.cornerRadius = 20.0
    }
    
    func updateChartWithData() {
        var dataEntries = [ChartDataEntry]()
        for i in 0..<self.m!.paymentSchedule.count {
            let remainingPrincipal = self.m!.paymentSchedule[i].remainingLoanBalance
            let remainingInterest = self.m!.paymentSchedule[i].remainingLoanCost
            let yValue = remainingPrincipal.adding(remainingInterest)
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(yValue))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Amortization")
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChart.data = chartData
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func extraPaymentButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toEditPayment", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! EditPaymentVC
        
        dest.m = self.m
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
