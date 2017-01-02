//
//  View7.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/13/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class View7: IntroDetailVC {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var exploreExtraPaymentsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatMessage()
        
        exploreExtraPaymentsButton.layer.borderColor = UIColor.clear.cgColor
        exploreExtraPaymentsButton.layer.borderWidth = 5.0
        exploreExtraPaymentsButton.layer.cornerRadius = 20.0
    }
    
    func formatMessage() {
        let string = message.text!
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Thin", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]
        
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "even more"))
        
        message.attributedText = attributedString
        message.sizeToFit()
    }
    
    @IBAction func exploreExtraPaymentsButtonAction(_ sender: UIButton) {
//        self.navigationController!.popViewController(animated: true)
        let rootViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = rootViewController
        // TODO: Pass self.mortgage!.originalMortgage to new rootViewController?
    }
    
//    func saveFirstMortgageBeforeSwitchingViews() {
//        UserDefaults.standard.set(self.mortgage!.originalMortgage, forKey: "intro_mortgage")
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
