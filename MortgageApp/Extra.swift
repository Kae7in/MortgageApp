////
////  Extra.swift
////  MortgageApp
////
////  Created by Kaelin Hooper on 1/3/17.
////  Copyright © 2017 Kaelin Hooper. All rights reserved.
////
//
//import Foundation
//import FirebaseAuth
//import FirebaseDatabase
//
//
//class Extra: NSObject {
//    var unique_id: String = UUID().uuidString
//    var associatedMortgage: Mortgage!
//    var startMonth: Int!
//    var endMonth: Int!
//    var extraIntervalMonths: Int!
//    var extraAmount: NSDecimalNumber!
//    
//    override init() {
//        super.init()
//    }
//    
//    init(_ extra: Extra) {
//        self.unique_id = extra.unique_id
//        self.associatedMortgage = extra.associatedMortgage
//        self.startMonth = extra.startMonth
//        self.endMonth = extra.endMonth
//        self.extraIntervalMonths = extra.extraIntervalMonths
//        self.extraAmount = extra.extraAmount
//    }
//    
//    func save() {
//        let user = FIRAuth.auth()?.currentUser
//        let ref = FIRDatabase.database().reference().child("mortgages").child(user!.uid).child(self.associatedMortgage.name).child("extraPayments").child(self.unique_id)
//        
//        ref.child("startMonth").setValue(self.startMonth)
//        ref.child("endMonth").setValue(self.endMonth)
//        ref.child("extraIntervalMonths").setValue(self.extraIntervalMonths)
//        ref.child("extraAmount").setValue(self.extraAmount)
//    }
//    
//    static func loadExtrasForMortgage(mortgage: Mortgage) -> [Extra] {
//        let user = FIRAuth.auth()?.currentUser
//        let ref = FIRDatabase.database().reference().child("mortgages/\(user!.uid)/\(mortgage.name)/extraPayments")
//        let query = ref.queryOrderedByKey()
//        
//        query.observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            for (_, extra_payment_dict) in value! {
//                let dict = extra_payment_dict as! NSDictionary
//                let extra: Extra = Extra()
//                
//                extra.associatedMortgage = mortgage
//                extra.unique_id = dict["unique_id"] as! String
//                extra.startMonth = dict["startMonth"] as! Int
//                extra.endMonth = dict["endMonth"] as! Int
//                extra.extraIntervalMonths = dict["extraIntervalMonths"] as! Int
//                extra.extraAmount = NSDecimalNumber(decimal: (dict["extraAmount"] as! NSNumber).decimalValue)
//                
//                // TODO: Add extras
//                let extras: [Dictionary<String, Int>] = []
//                mortgage.extras = extras
//                
//                self.mortgageData.mortgages.append(mortgage)
//            }
//        })
//        
//        let extra = [Extra()]
//        return extra
//    }
//}
