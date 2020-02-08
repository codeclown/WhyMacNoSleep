//
//  PmsetWatcher.swift
//  WhyMacNoSleep
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Foundation
import os

class PmsetWatcher: NSObject {
    var handler: ((PmsetAssertion) -> ())!
    let lineOutputter = LineOutputter()
    
    func start() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.onFileHandleDataAvailable),
//            name: NSNotification.Name.NSFileHandleDataAvailable,
//            object: nil
//        )
        
        let pipe = Pipe()
        let handle = pipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", "pmset -g assertionslog"];
        process.standardOutput = pipe
        
        handle.waitForDataInBackgroundAndNotify()
        process.launch()
    }
    
    @objc func onFileHandleDataAvailable(_ notification: Notification) {
        let fileHandle = notification.object as! FileHandle
        let availableData = fileHandle.availableData

        os_log("Received notification: %d", availableData.count)
        
        if availableData.count > 0 {
            let data = String.init(data: availableData, encoding: String.Encoding.utf8)
            let lines = lineOutputter.feed(data!)
            print(lines)
            for line in lines {
                onLine(line)
            }
            fileHandle.waitForDataInBackgroundAndNotify()
        }
    }
    
    func onLine(_ line: String) {
        os_log("Received line: %s", line)
        let pmsetAssertion = PmsetOutputParser.parseLine(line)
        if pmsetAssertion != nil {
            os_log("Parsed assertion: %s", pmsetAssertion.debugDescription)
            handler(pmsetAssertion!)
        }
    }
}
