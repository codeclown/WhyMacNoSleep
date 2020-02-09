//
//  LineOutputterTests.swift
//  WhyMacNoSleepTests
//
//  Created by Martti on 09/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import XCTest
@testable import WhyMacNoSleep

class LineOutputterTests: XCTestCase {
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
}
