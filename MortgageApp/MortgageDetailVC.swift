//
//  MortgageDetailVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit
import Charts

class MortgageDetailVC: UIViewController, ChartViewDelegate {
    
    var mortgage: Mortgage? = nil
    var mc: MortgageCalculator = MortgageCalculator()
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceCents: UILabel!
    @IBOutlet weak var yearsLeftLabel: UILabel!
    @IBOutlet weak var monthsLeftLabel: UILabel!
    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    let segment:UISegmentedControl = UISegmentedControl(items: ["Total", "Principal", "Interest"])
    
    @IBOutlet weak var lineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        m!.extras = [["startMonth":1, "endMonth":360, "extraIntervalMonths":12, "extraAmount":Int(m!.monthlyPayment)]]
        mortgage = mc.calculateMortgage(mortgage: mortgage!)
        layoutViews()
    }
    
    func layoutViews() {
        // TODO: Use current balance remaining and current time left
        updateLabels(balanceLeft: mortgage!.loanAmount().adding(mortgage!.totalLoanCost), timeLeft: self.mortgage!.numberOfPayments)
        layoutNavigationBar()
        layoutExtraPaymentButton()
        layoutChart()
        updateChartWithData(type: "Total")
    }
    
    func updateLabels(balanceLeft: NSNumber, timeLeft: Int) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let balanceComponents = numberFormatter.string(from: balanceLeft)!.components(separatedBy: ".")
        
        balance.text! = balanceComponents.first!
        if balanceComponents.count > 1 {
            balanceCents.text! = "." + balanceComponents.last!
        } else {
            balanceCents.text! = ".00"
        }
        
        let yearsLeft = timeLeft / 12
        let remainingMonthsLeft = timeLeft % 12
        
        self.yearsLeftLabel.text! = String(yearsLeft) + "yr"
        self.monthsLeftLabel.text! = String(remainingMonthsLeft) + "mo"
    }
    
    func layoutNavigationBar() {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1.0)
        self.navigationItem.title = "Mortgage Balance"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(extraPaymentButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
        
        segment.addTarget(self, action: #selector(changeBalanceType), for: .valueChanged)
        segment.sizeToFit()
        segment.tintColor = UIColor(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1.0)
        segment.selectedSegmentIndex = 0
//        self.navigationItem.titleView = segment
        let f = self.navigationController!.navigationBar.frame
        segment.frame = CGRect(x: f.minX + 80.0, y: f.minY + 50.0, width: f.width - 160.0, height: 30.0)
        self.view.addSubview(segment)
    }
    
    func changeBalanceType(sender: UISegmentedControl) {
        let str = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        if str == "Total" {
            // TODO: Add balance remaining given current date and time remaining given current date
            updateLabels(balanceLeft: self.mortgage!.totalLoanCost.adding(self.mortgage!.loanAmount()), timeLeft: self.mortgage!.loanTermMonths)
        } else if str == "Principal" {
            updateLabels(balanceLeft: self.mortgage!.loanAmount(), timeLeft: self.mortgage!.loanTermMonths)
        } else if str == "Interest" {
            updateLabels(balanceLeft: self.mortgage!.totalLoanCost, timeLeft: self.mortgage!.loanTermMonths)
        }
        
        updateChartWithData(type: str)
    }
    
    func layoutExtraPaymentButton() {
//        extraPaymentButton.layer.borderColor = UIColor.clear.cgColor
//        extraPaymentButton.layer.borderWidth = 5.0
//        extraPaymentButton.layer.cornerRadius = 20.0
    }
    
    func layoutChart() {
        lineChart.chartDescription?.enabled = false
        lineChart.drawGridBackgroundEnabled = false
        lineChart.legend.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.leftAxis.spaceBottom = 0.1
        lineChart.setViewPortOffsets(left: 5.0, top: 0.0, right: 7.0, bottom: 20.0)
        lineChart.setScaleEnabled(false)
        lineChart.doubleTapToZoomEnabled = false
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.setLabelCount(self.mortgage!.loanTermMonths / (5*12), force: false)
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.animate(xAxisDuration: 0.5, easingOption: ChartEasingOption.easeInQuart)
//        let yAx = lineChart.leftAxis
//        yAx.axisMaximum = self.m!.paymentSchedule[0].remainingLoanBalance.adding(self.m!.totalLoanCost).doubleValue
        
        let marker: BalloonMarker = BalloonMarker(color: UIColor.gray, font: UIFont(name: ".SFUIDisplay-Thin", size: 16.0)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 20.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        marker.chartView = self.lineChart
        lineChart.marker = marker
        
        lineChart.delegate = self
    }
    
    func updateChartWithData(type: String) {
        var dataEntries = [ChartDataEntry]()
        let termYears = self.mortgage!.loanTermMonths / 12
        for i in 0...termYears {
            var dataEntry: ChartDataEntry!
            var j = (i * 12) - 1
            j = j < 0 ? 0 : j
            var yValue = NSDecimalNumber(value: 0.0)
            
            if j >= self.mortgage!.numberOfPayments {
                yValue = 0
                dataEntry = ChartDataEntry(x: Double(i), y: Double(yValue), data: nil)
            } else if type == "Total" {
                let remainingPrincipal = self.mortgage!.paymentSchedule[j].remainingLoanBalance
                let remainingInterest = self.mortgage!.paymentSchedule[j].remainingLoanCost
                yValue = remainingPrincipal.adding(remainingInterest)
                dataEntry = ChartDataEntry(x: Double(i), y: Double(yValue), data: self.mortgage!.paymentSchedule[j])
            } else if type == "Principal" {
                yValue = self.mortgage!.paymentSchedule[j].remainingLoanBalance
                dataEntry = ChartDataEntry(x: Double(i), y: Double(yValue), data: self.mortgage!.paymentSchedule[j])
            } else if type == "Interest" {
                yValue = self.mortgage!.paymentSchedule[j].remainingLoanCost
                dataEntry = ChartDataEntry(x: Double(i), y: Double(yValue), data: self.mortgage!.paymentSchedule[j])
            }
            
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Amortization")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(NSUIColor(cgColor: UIColor(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 1).cgColor))
        chartDataSet.lineWidth = 4.0
        
        let fromColor = UIColor(rgbColorCodeRed: 208, green: 2, blue: 27, alpha: 0.1)
        let gradientColors = [fromColor.cgColor, UIColor.white.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)
        chartDataSet.fillAlpha = 1.0
        chartDataSet.fill = Fill(linearGradient: gradient!, angle: -90.0)
        chartDataSet.drawFilledEnabled = true
        
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChart.data = chartData
        lineChart.animate(xAxisDuration: 0.2, easingOption: ChartEasingOption.easeInQuart)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let amortization = entry.data {
            let a = amortization as! Amortization
            let timeLeft = self.mortgage!.paymentSchedule.count - a.loanMonth
            updateLabels(balanceLeft: NSDecimalNumber(value: highlight.y), timeLeft: Int(timeLeft))
        } else {
            updateLabels(balanceLeft: NSDecimalNumber(value: 0.00), timeLeft: 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func extraPaymentButtonAction(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toEditPayment", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! EditPaymentVC
        
        dest.mortgage = self.mortgage
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
