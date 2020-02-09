//
//  ViewController.swift
//  WhyMacNoSleep
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Cocoa

// These are the locks that prevent the system from sleeping
let RelevantLocks = [
    "PreventUserIdleSystemSleep",
    "PreventSystemSleep"
]

struct ListItem {
    var date: Date
    var action: String
    var name: String
    var applicationInfos: [ApplicationInfo]
}

class ViewController: NSViewController {
    @IBOutlet var tableContainer: NSScrollView!
    
    var table: AssertionTable!
    var listItems: [ListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table = AssertionTable()
        tableContainer.documentView = table.getTableView()
        
        // Uncomment for local testing
        // addDebugItems()
        
        let watcher = PmsetWatcher()
        // Adding the observer inside PmsetWatcher.start did not
        // function as expected. Something to do with threads...
        NotificationCenter.default.addObserver(
            forName: .NSFileHandleDataAvailable,
            object: nil,
            queue: nil
        ) { (notification) in
            watcher.onFileHandleDataAvailable(notification)
        }
        watcher.handler = onNewAssertion
        watcher.start()
        
        let systemPowerWatcher = SystemPowerWatcher()
//        systemPowerWatcher.start()
    }
    
    func onNewAssertion(_ pmsetAssertion: PmsetAssertion) {
        if RelevantLocks.contains(pmsetAssertion.type) {
            let applicationInfos = PidResolver.resolvePid(pmsetAssertion.pid)
            let listItem = ListItem(
                date: pmsetAssertion.date,
                action: pmsetAssertion.action,
                name: pmsetAssertion.name,
                applicationInfos: applicationInfos
            )
            addListItem(listItem)
        }
    }
    
    func addListItem(_ listItem: ListItem) {
        listItems.append(listItem)
        table.items = listItems
        table.refresh()
    }
    
    func addDebugItems() {
        // A couple of assertions which will resolve to unknown applications
        for assertion in [
            PmsetAssertion(date: Date(), action: "Created", type: "PreventUserIdleSystemSleep", pid: Int32(1234), id: "0x87473000b841f", name: "userInactivePowerAssertion"),
            PmsetAssertion(date: Date(), action: "Released", type: "PreventUserIdleSystemSleep", pid: Int32(1234), id: "0x87473000b841f", name: "userInactivePowerAssertion")
        ] {
            onNewAssertion(assertion)
        }
        
//        let dummyIcon = NSWorkspace().runningApplications.first { (application) -> Bool in
//            return application.icon != nil
//        }!.icon!
//        for item in [
//            ListItem(
//                date: Date(),
//                action: "Created",
//                applications: [
//                    ApplicationInfo(name: "Test app 1", icon: dummyIcon)
//                ]
//            ),
//            ListItem(
//                date: Date(),
//                action: "Released",
//                applications: [
//                    ApplicationInfo(name: "Test app 1", icon: dummyIcon)
//                ]
//            )
//        ] {
//            addListItem(item)
//        }
    }
}
