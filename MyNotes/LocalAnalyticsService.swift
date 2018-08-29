/*
 * Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
 * except in compliance with the License. A copy of the License is located at
 *
 *    http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for
 * the specific language governing permissions and limitations under the License.
 */

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
