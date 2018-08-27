//
//  AnalyticsService.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/27/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

/*
 * Methods associated with analytics
 */
protocol AnalyticsService {
    func recordEvent(_ eventName: String, parameters: [String:String]?, metrics: [String:Double]?) -> Void
}
