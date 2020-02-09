//
//  SystemPowerWatcher.swift
//  WhyMacNoSleep
//
//  Created by Martti on 09/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Foundation
import os
import IOKit.pwr_mgt

class SystemPowerWatcher {
    func start() {
        var refcon = 0
//        var notify = OpaquePointer(UnsafeMutableRawPointer(&refCon))
//        var notify: UnsafeMutablePointer<IONotificationPortRef?>? = refCon
//        var asd = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
        var notify: UnsafeMutablePointer<IONotificationPortRef?>?
//        var iterator: io_object_t
        var iterator: UnsafeMutablePointer<UInt32>?
        
        func onNotification (refcon: UnsafeMutableRawPointer?, service: UInt32, messageType: UInt32, messageArgument: UnsafeMutableRawPointer?) {
            print(refcon, service, messageType, messageArgument)
        }
        
        // Following this implementation:
        // https://stackoverflow.com/a/51366895/239527
        
        // IORegisterForSystemPower
        let rootPort = IORegisterForSystemPower(
            &refcon,
            notify,
            onNotification,
            iterator
        )
        
        if (rootPort == IO_OBJECT_NULL) {
            os_log("IORegisterForSystemPower failed")
            return
        }
        
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            IONotificationPortGetRunLoopSource(OpaquePointer(notify)) as! CFRunLoopSource,
            CFRunLoopMode.defaultMode
        )
    }
}
