// Created by Pavel Holyavkin on 4/26/21
// Copyright © 2021 App Incubator, Inc. All rights reserved.

import Foundation

extension Date {
    var getDateInStringPT: String {
        let format = DateFormatter()
        format.timeZone = TimeZone(abbreviation: "PST")
        format.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let dateString = format.string(from: self)
        
        return dateString
    }
}
