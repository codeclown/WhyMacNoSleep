//
//  PmsetOutputParser.swift
//  WhyMacNoSleep
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Foundation

struct PmsetAssertion: Equatable {
    var date: Date
    var action: String
    var type: String
    var pid: String
    var id: String
    var name: String
}

class PmsetOutputParser {
    static func parseLine(_ line: String) -> PmsetAssertion? {
        // 02/06 22:29:51
        let range = NSRange(location: 0, length: line.count)
        let regex = try! NSRegularExpression(pattern: "^[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} ")
        if regex.firstMatch(in: line, options: [], range: range) == nil {
            return nil
        }
        
        let segments = line
            .components(separatedBy: " ")
            .filter { $0 != "" }
            
        let date = segments[0]
        let time = segments[1]
        let action = segments[2]
        let type = segments[3]
        let pid = segments[4]
        let id = segments[5]
        let name = segments[6]
        
        if action == "System" && type == "wide" {
            return nil
        }
        
        let pmsetAssertion = PmsetAssertion(
            date: PmsetOutputParser.parseDate(date, time),
            action: action,
            type: type,
            pid: pid,
            id: id,
            name: name
        )
        
        return pmsetAssertion
    }
    
    static func parseDate(_ date: String, _ time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        let year = Calendar.current.component(.year, from: Date())
        let result = dateFormatter.date(from: "\(year)-\(date) \(time)")!
        return result
    }
}
