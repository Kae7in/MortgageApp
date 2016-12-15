//
//  View2.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View2: IntroDetailVC {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var principalLabel: UILabel!
    @IBOutlet weak var extraPaymentLabel: UILabel!
    @IBOutlet weak var newPrincipalLabel: UILabel!
    var displayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        formatMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !displayed {
            displayed = true
            displayMortgageData()
        }
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "extra"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    func displayMortgageData() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        principalLabel.text! = numberFormatter.string(from: mortgage!.loanAmount())!.components(separatedBy: ".")[0]
        newPrincipalLabel.text! = principalLabel.text!
        
        var value = self.mortgage!.monthlyPayment
        animate(label: extraPaymentLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, increment: 10, interval: 0.001)
        value = self.mortgage!.loanAmount().subtracting(self.mortgage!.monthlyPayment)
        animate(label: newPrincipalLabel, startValue: NSDecimalNumber(value: 0.0), endValue: value, increment: -10, interval: 0.001)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
