//
//  ViewController.swift
//  WhyMacNoSleep
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Cocoa
import os

class ViewController: NSViewController {
    var pmsetAssertions: [PmsetAssertion] = []
    let lineOutputter = LineOutputter()
    
    @IBOutlet var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        pmsetAssertions += [
            PmsetAssertion(date: Date(), action: "Created", type: "BackgroundTask", pid: "298", id: "0x87473000b841f", name: "com.apple.metadata.mds_stores.power"),
            PmsetAssertion(date: Date(), action: "Released", type: "BackgroundTask", pid: "298", id: "0x87473000b841f", name: "com.apple.metadata.mds_stores.power"),
            PmsetAssertion(date: Date(), action: "Created", type: "BackgroundTask", pid: "306(336)", id: "0x87474000b8420", name: "com.apple.cloudkit.packageGarbageCollection"),
            PmsetAssertion(date: Date(), action: "Created", type: "BackgroundTask", pid: "306(336)", id: "0x87474000b8421", name: "com.apple.cloudkit.pcs.memorycache.evict"),
            PmsetAssertion(date: Date(), action: "Released", type: "BackgroundTask", pid: "306(336)", id: "0x87474000b8420", name: "com.apple.cloudkit.packageGarbageCollection"),
            PmsetAssertion(date: Date(), action: "Released", type: "BackgroundTask", pid: "306(336)", id: "0x87474000b8421", name: "com.apple.cloudkit.pcs.memorycache.evict")
        ]

        beginWatching()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }

    func onNewPmsetLine(_ line: String) {
        os_log("Received line: %s", line)
        let pmsetAssertion = PmsetOutputParser.parseLine(line)
        if pmsetAssertion != nil {
            os_log("Parsed assertion: %s", pmsetAssertion.debugDescription)
            pmsetAssertions.append(pmsetAssertion!)
            // TODO scroll only if was already scrolled to bottom
            tableView.reloadData()
            tableView.scrollRowToVisible(pmsetAssertions.count)
        }
    }

    func beginWatching() {
        NotificationCenter.default.addObserver(self,
           selector: #selector(self.commandOutputNotification),
           name: NSNotification.Name.NSFileHandleDataAvailable,
           object: nil)
        
        let pipe = Pipe()
        
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", "pmset -g assertionslog"];
        process.standardOutput = pipe
        
        let handle = pipe.fileHandleForReading
        handle.waitForDataInBackgroundAndNotify()
        
        process.launch()
    }
    
    @objc func commandOutputNotification(_ notification: Notification) {
        let fileHandle = notification.object as! FileHandle
        let availableData = fileHandle.availableData

        if availableData.count > 0 {
            let data = String.init(data: availableData, encoding: String.Encoding.utf8)
            let lines = lineOutputter.feed(data!)
            for line in lines {
                onNewPmsetLine(line)
            }
            fileHandle.waitForDataInBackgroundAndNotify()
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pmsetAssertions.count
    }
}

extension ViewController: NSTableViewDelegate {
    // https://www.appcoda.com/macos-programming-tableview/
    
    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let pmsetAssertion = pmsetAssertions[row]
        
        if tableColumn == nil {
            return nil
        }

        if let cell = getCellViewFor(tableColumn, name: "date") {
            cell.textField?.stringValue = pmsetAssertion.date.description
            return cell
        }

        if let cell = getCellViewFor(tableColumn, name: "action") {
            cell.textField?.stringValue = pmsetAssertion.action
            return cell
        }

        if let cell = getCellViewFor(tableColumn, name: "type") {
            cell.textField?.stringValue = pmsetAssertion.type
            return cell
        }

        if let cell = getCellViewFor(tableColumn, name: "pid") {
            cell.textField?.stringValue = pmsetAssertion.pid
            return cell
        }

        if let cell = getCellViewFor(tableColumn, name: "id") {
            cell.textField?.stringValue = pmsetAssertion.id
            return cell
        }

        if let cell = getCellViewFor(tableColumn, name: "name") {
            cell.textField?.stringValue = pmsetAssertion.name
            return cell
        }
        
        return nil
    }
    
    func getCellViewFor(_ tableColumn: NSTableColumn?, name: String) -> NSTableCellView? {
        let columnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "\(name)Column")
        let cellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "\(name)CellView")
        
        if tableColumn?.identifier == columnIdentifier {
            let cellView = tableView.makeView(withIdentifier: cellViewIdentifier, owner: self) as! NSTableCellView
            return cellView
        }
        
        return nil
    }
}
