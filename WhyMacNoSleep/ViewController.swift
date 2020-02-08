//
//  ViewController.swift
//  WhyMacNoSleep
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var tableContainer: NSScrollView!
    var table: AssertionTable!
    var pmsetAssertions: [PmsetAssertion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table = AssertionTable()
        tableContainer.documentView = table.getTableView()
        
        // Uncomment for local testing
//        addDebugItems()
        
        let watcher = PmsetWatcher()
        NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: nil) { (notification) in
            watcher.onFileHandleDataAvailable(notification)
        }
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.onFileHandleDataAvailable),
//            name: NSNotification.Name.NSFileHandleDataAvailable,
//            object: nil
//        )
        watcher.handler = onNewAssertion
        watcher.start()
    }
    
    func onNewAssertion(_ pmsetAssertion: PmsetAssertion) {
//        print(pmsetAssertion)
        if pmsetAssertion.type == "PreventUserIdleSystemSleep" {
            pmsetAssertions.append(pmsetAssertion)
            table.items = pmsetAssertions;
            table.refresh();
        }
    }
    
    func addDebugItems() {
        for assertion in [
            PmsetAssertion(date: Date(), action: "Created", type: "PreventUserIdleSystemSleep", pid: "298", id: "0x87473000b841f", name: "userInactivePowerAssertion"),
            PmsetAssertion(date: Date(), action: "Released", type: "PreventUserIdleSystemSleep", pid: "298", id: "0x87473000b841f", name: "userInactivePowerAssertion"),
            PmsetAssertion(date: Date(), action: "Created", type: "PreventUserIdleSystemSleep", pid: "306(336)", id: "0x87474000b8420", name: "com.apple.WebCore: HTMLMediaElement playback")
        ] {
            onNewAssertion(assertion)
        }
    }
}
