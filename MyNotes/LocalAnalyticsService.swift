//
//  LocalAnalyticsService.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/27/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

import Foundation

/*
 * Implementation of the Analytics Service that prints to the local debug log
 */
class LocalAnalyticsService : AnalyticsService {
    init() {
        print("LocalAnalyticsService: session-start")
    }
    
    func recordEvent(_ eventName: String, parameters: [String : String]?, metrics: [String : Double]?) {
        var event = ""
        if (parameters != nil) {
            for (key, value) in parameters! {
                event += ",\"\(key)\"=\"\(value)\""
            }
        }
        if (metrics != nil) {
            for (key, value) in metrics! {
                let formattedValue = String(format:"%.2f", value)
                event += ",\"\(key)=\(formattedValue)"
            }
        }
        if (event.count > 0) {
            event = String(event.dropFirst(1))
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = Date()
        let dateString = df.string(from: currentTime)
        print("\(dateString) \(eventName):\(event)")
    }
}
