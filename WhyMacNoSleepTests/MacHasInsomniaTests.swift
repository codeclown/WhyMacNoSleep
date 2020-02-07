//
//  MacHasInsomniaTests.swift
//  MacHasInsomniaTests
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import XCTest
@testable import MacHasInsomnia

class MacHasInsomniaTests: XCTestCase {
    func testLineOutputter() {
        let outputter = LineOutputter()
        XCTAssertEqual(outputter.feed(""), [])
        XCTAssertEqual(outputter.feed("line 1"), [])
        XCTAssertEqual(outputter.feed("\n"), ["line 1"])
        XCTAssertEqual(outputter.feed("more stuff\nand more"), ["more stuff"])
        XCTAssertEqual(outputter.feed("foobar"), [])
        XCTAssertEqual(outputter.feed("\ny\nes"), ["and morefoobar", "y"])
        XCTAssertEqual(outputter.feed(" alright\n"), ["es alright"])
    }
    
    func testParseDate() {
        var dateComponents = DateComponents()
        dateComponents.year = Calendar.current.component(.year, from: Date())
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation()!)
        dateComponents.hour = 8
        dateComponents.minute = 34
        dateComponents.second = 10
        let expected = Calendar.current.date(from: dateComponents)
        XCTAssertEqual(PmsetOutputParser.parseDate("07/11", "08:34:10"), expected)
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
            "   pid 158(coreaudiod): [0x000831dd0001a326] 00:19:45 PreventUserIdleSystemSleep named: \"com.apple.audio.08-df-1f-e0-08-ad:output.context.preventuseridlesleep\" ",
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
        ]
        
        for line in nilLines {
            XCTAssertEqual(PmsetOutputParser.parseLine(line), nil)
        }
        
        let line1 = "02/06 22:29:51   Created     BackgroundTask                298                 0x83698000ba3ba     com.apple.metadata.mds_stores.power               "
        let expected1 = PmsetAssertion(
            date: PmsetOutputParser.parseDate("02/06", "22:29:51"),
            action: "Created",
            type: "BackgroundTask",
            pid: "298",
            id: "0x83698000ba3ba",
            name: "com.apple.metadata.mds_stores.power"
        )
        XCTAssertEqual(PmsetOutputParser.parseLine(line1)!, expected1)
        
        let line2 = "02/06 22:29:52   Released    BackgroundTask                298                 0x83698000ba3ba     com.apple.metadata.mds_stores.power               "
        let expected2 = PmsetAssertion(
            date: PmsetOutputParser.parseDate("02/06", "22:29:52"),
            action: "Released",
            type: "BackgroundTask",
            pid: "298",
            id: "0x83698000ba3ba",
            name: "com.apple.metadata.mds_stores.power"
        )
        XCTAssertEqual(PmsetOutputParser.parseLine(line2), expected2)
    }
}
