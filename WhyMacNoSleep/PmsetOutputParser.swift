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
    var pid: Int32
    var id: String
    var name: String
}

class PmsetOutputParser {
    static func parseLine(_ line: String) -> PmsetAssertion? {
        let range = NSRange(location: 0, length: line.count)
        
        // "02/08 20:34:27   ClientDied  PreventUserIdleSystemSleep    80611(80593)        0x9182f00019583     caffeinate command-line tool"
        let lineRegex = try! NSRegularExpression(pattern:
            "^(?<date>[0-9]{2}/[0-9]{2}) +" +
            "(?<time>[0-9]{2}:[0-9]{2}:[0-9]{2}) +" +
            "(?<action>[A-Za-z]+) +" +
            "(?<type>[A-Za-z]+) +" +
            "(?<pid>[0-9]+(?:\\([0-9]+\\))?) +" +
            "(?<id>[0-9a-z]+) +" +
            "(?<name>[^\\s].+) *$"
        )
        let match = lineRegex.firstMatch(in: line, options: [], range: range)
        if match == nil {
            return nil
        }

        var values = [String: String]()
        for name in ["date", "time", "action", "type", "pid", "id", "name"] {
            let foo = match?.range(withName: name)
            if foo != nil {
                let groupRange = Range(foo!, in: line)
                let value = line.substring(with: groupRange!)
                values[name] = value
            }
        }
        
        let date = values["date"]!
        let time = values["time"]!
        let action = values["action"]!
        let type = values["type"]!
        let pid = parsePidFromString(values["pid"]!)
        let id = values["id"]!
        let name = values["name"]!.trimmingCharacters(in: .whitespaces)
        
        if pid == nil {
            return nil
        }
        
        let pmsetAssertion = PmsetAssertion(
            date: PmsetOutputParser.parseDate(date, time),
            action: action,
            type: type,
            pid: pid!,
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
    
    static func parsePidFromString(_ pid: String) -> Int32? {
        if pid.contains("(") {
            let range = NSRange(location: 0, length: pid.count)
            let regex = try! NSRegularExpression(pattern: "^[0-9]+\\(([0-9]+)\\)$")
            let match = regex.firstMatch(in: pid, options: [], range: range)
            let foo = match?.range(at: 1)
            if foo == nil {
                return nil
            }
            let groupRange = Range(foo!, in: pid)
            let value = pid.substring(with: groupRange!)
            return Int32(value)
        } else {
            return Int32(pid)
        }
    }
}
