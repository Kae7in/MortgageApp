//
//  UNNotificationRequest+payments.swift
//  MortgageApp
//
//  Created by Christopher Combes on 1/25/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UserNotifications

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
