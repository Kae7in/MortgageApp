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
    
    // Number animation stuff
    var extraPaymentCounter: NSDecimalNumber = 0.0
    var newPrincipalCounter: NSDecimalNumber = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newPrincipalCounter = mortgage!.loanAmount()
        
        formatMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayMortgageData()
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
        principalLabel.text! = mortgage!.loanAmount().stringValue.components(separatedBy: ".")[0]
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.monthlyPayment
            self.extraPaymentCounter = self.animate(label: self.extraPaymentLabel, value: value, timer: timer, counter: self.extraPaymentCounter, increment: 1)
        }
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            let value: NSDecimalNumber = self.mortgage!.loanAmount().subtracting(self.mortgage!.monthlyPayment)
            self.newPrincipalCounter = self.animate(label: self.newPrincipalLabel, value: value, timer: timer, counter: self.newPrincipalCounter, increment: -1)
        }
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
