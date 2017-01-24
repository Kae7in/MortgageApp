//
//  CustomExtensions.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/17/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications



extension UIColor {
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
        
    }
    
    
    static func primary(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 227, green: 71, blue: 52, alpha: alpha)
    }
    
    
    static func secondary(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 74, green: 74, blue: 74, alpha: alpha)
    }
    
    
    static func customGrey(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(rgbColorCodeRed: 247, green: 247, blue: 247, alpha: 1.0)
    }
    
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



extension UNNotificationRequest {
    
    static func setPaymentReminderNotification(mortgage: Mortgage) {
        // Notification content
        let content = UNMutableNotificationContent()
        content.title = mortgage.name + " Montly Payment"
        content.body = "Put some extra money towards your upcoming monthly payment."
        content.sound = UNNotificationSound.default()
        
        // Trigger date
        let date = Date(timeIntervalSinceNow: 10)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,],
                                                          from: date)
        
        // Trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        
        // Request
        let identifier = mortgage.name + "payment_notification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                // Something went wrong
            }
        })
    }
    
    
    func removePaymentReminderNotification(mortgage: Mortgage) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiers: [String] = []
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == mortgage.name + "payment_notification" {
                    identifiers.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}
