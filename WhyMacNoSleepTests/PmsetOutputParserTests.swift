//
//  PmsetOutputParserTests.swift
//  WhyMacNoSleepTests
//
//  Created by Martti on 09/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import XCTest
@testable import WhyMacNoSleep

class PmsetOutputParserTests: XCTestCase {
    func testParseDate() {
        let expected = makeDate(11, 7, 8, 34, 10)
        XCTAssertEqual(PmsetOutputParser.parseDate("07/11", "08:34:10"), expected)
    }
    
    func makeDate(_ day: Int, _ month: Int, _ hour: Int, _ minute: Int, _ second: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation()!)
        let currentYear = Calendar.current.component(.year, from: Date())
        dateComponents.year = currentYear
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        return Calendar.current.date(from: dateComponents)!
    }

    func testParseLine() {
        let nilLines = [
            "2020-02-06 22:29:26 +0100 : Showing all currently held IOKit power assertions",
            "Assertion status system-wide:",
            "   BackgroundTask                 0",
            "   ApplePushServiceTask           0",
            "   UserIsActive                   1",
            "   PreventUserIdleDisplaySleep    0",
            "   PreventSystemSleep             0",
            "   ExternalMedia                  0",
            "   PreventUserIdleSystemSleep     1",
            "   NetworkClientActive            0",
            "   Listed by owning process:",
            // line like "pid 158(coreaudiod):..." was here originally,
            "   \tCreated for PID: 12435. ",
            "   pid 125(hidd): [0x00082b5b0009a0d8] 00:00:00 UserIsActive named: \"com.apple.iohideventsystem.queue.tickle.4295033286.11\" ",
            "   \tTimeout will fire in 180 secs Action=TimeoutActionRelease",
            "No kernel assertions.",
            "Idle sleep preventers: IODisplayWrangler",
            "",
            "Showing assertion changes(Press Ctrl-T to log all currently held assertions):",
            "",
            "Time             Action      Type                          PID(Causing PID)    ID                  Name                                              ",
            "====             ======      ====                          ================    ==                  ====                                              ",
            "02/07 21:03:33   System wide status: PreventUserIdleDisplaySleep: 1",
            "02/07 21:03:33   System wide status: PreventUserIdleDisplaySleep: 0",
        ]
        
        for line in nilLines {
            XCTAssertEqual(PmsetOutputParser.parseLine(line), nil)
        }
        
        let line1 = "02/06 22:29:51   Created     BackgroundTask                298                 0x83698000ba3ba     com.apple.metadata.mds_stores.power               "
        let expected1 = PmsetAssertion(
            date: PmsetOutputParser.parseDate("02/06", "22:29:51"),
            action: "Created",
            type: "BackgroundTask",
            pid: Int32(298),
            id: "0x83698000ba3ba",
            name: "com.apple.metadata.mds_stores.power"
        )
        XCTAssertEqual(PmsetOutputParser.parseLine(line1)!, expected1)
        
        let line2 = "02/06 22:29:52   Released    BackgroundTask                298                 0x83698000ba3ba     com.apple.metadata.mds_stores.power               "
        let expected2 = PmsetAssertion(
            date: PmsetOutputParser.parseDate("02/06", "22:29:52"),
            action: "Released",
            type: "BackgroundTask",
            pid: Int32(298),
            id: "0x83698000ba3ba",
            name: "com.apple.metadata.mds_stores.power"
        )
        XCTAssertEqual(PmsetOutputParser.parseLine(line2), expected2)
        
        let line3 = "02/08 20:34:27   ClientDied  PreventUserIdleSystemSleep    80611(80593)        0x9182f00019583     caffeinate command-line tool"
        let expected3 = PmsetAssertion(
            date: PmsetOutputParser.parseDate("02/08", "20:34:27"),
            action: "ClientDied",
            type: "PreventUserIdleSystemSleep",
            pid: Int32(80593),
            id: "0x9182f00019583",
            name: "caffeinate command-line tool"
        )
        XCTAssertEqual(PmsetOutputParser.parseLine(line3), expected3)

        //        let line4 = "   pid 158(coreaudiod): [0x000831dd0001a326] 00:19:45 PreventUserIdleSystemSleep named: \"com.apple.audio.08-df-1f-e0-08-ad:output.context.preventuseridlesleep\" "
        //        let expecte4 = PmsetAssertion(
        //            date: PmsetOutputParser.parseDate("02/06", "22:29:52"),
        //            action: "Released",
        //            type: "BackgroundTask",
        //            pid: Int32(298),
        //            id: "0x83698000ba3ba",
        //            name: "com.apple.metadata.mds_stores.power"
        //        )
        //        XCTAssertEqual(PmsetOutputParser.parseLine(line4), expected4)
    }
}
