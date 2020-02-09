//
//  PidResolver.swift
//  WhyMacNoSleep
//
//  Created by Martti on 08/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Cocoa
import Foundation
import os

struct ApplicationInfo: Equatable {
    var pid: Int32
    var name: String?
    var icon: NSImage?
}

class PidResolver {
    static func resolvePid(_ pid: pid_t) -> [ApplicationInfo] {
        var pids: [pid_t] = [pid]
        
        while true {
            let previous = pids.last
            let ppid = PidResolver.getPpid(previous!)
            if ppid == nil {
                break
            }
            pids.append(ppid!)
        }
        
        os_log("Found %d pids for %d", pids.count, pids[0])
        for item in pids {
            os_log("  - %d", item)
        }
        
        let runningApplications = NSWorkspace().runningApplications;
        
        let applications = pids.map { (pid) -> NSRunningApplication? in
            return runningApplications.first { (application) -> Bool in
                return application.processIdentifier == pid
            }
        }
        
        os_log("Running applications:")
        for application in applications {
            os_log("%s", application?.localizedName ?? "nil")
        }
        
        let applicationInfos = applications.filter { (application) -> Bool in
            return application != nil
        }.map { (application) -> ApplicationInfo in
            return ApplicationInfo(
                pid: Int32(application!.processIdentifier),
                name: application!.localizedName,
                icon: application!.icon
            )
        }

        return applicationInfos
    }
    
    static func getPpid(_ pid: pid_t) -> pid_t? {
        // Executing `ps` requires elevated privileges, so
        // unfortunately this approach is not feasible.
        // Commenting out for now.
        
//        let command = "ps -o ppid= -p \(pid)"
//        let task = Process()
//        task.launchPath = "/bin/bash"
//        task.arguments = ["-c", command]
//
//        let pipe = Pipe()
//        task.standardError = pipe
//        task.launch()
//
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
//
//        os_log("%s: %s", command, output)

        return nil
    }
}
