//
//  AssertionTable.swift
//  WhyMacNoSleep
//
//  Created by Martti on 07/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Cocoa

class AssertionTable: NSObject {
    var table = NSTableView()
    let dateFormatter = DateFormatter()
    var items: [PmsetAssertion] = []
    
    override init() {
        super.init()
        
        createColumns()
        
        table.delegate = self
        table.dataSource = self
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
    }
    
    func getTableView() -> NSTableView {
        return table
    }
    
    func createColumns() {
        let timeColumn = NSTableColumn()
        timeColumn.headerCell.title = "Time"
        timeColumn.width = 40
        table.addTableColumn(timeColumn)
        
        let eventColumn = NSTableColumn()
        eventColumn.headerCell.title = "Event"
        eventColumn.width = 140
        table.addTableColumn(eventColumn)
        
        let nameColumn = NSTableColumn()
        nameColumn.headerCell.title = "Name"
        nameColumn.width = 300
        table.addTableColumn(nameColumn)
    }
    
    func refresh() {
//        print(items)
        table.reloadData()
    }
}

extension AssertionTable: NSTableViewDataSource {
   func numberOfRows(in tableView: NSTableView) -> Int {
       return items.count
   }
}

extension AssertionTable: NSTableViewDelegate {
    // https://www.appcoda.com/macos-programming-tableview/

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        if tableColumn == nil {
            return nil
        }
        
        let pmsetAssertion = items[row]
        let cell = NSTableCellView()
        
        if tableColumn == table.tableColumns[0] {
            let text = dateFormatter.string(from: pmsetAssertion.date)
            let textField = NSTextField(labelWithString: text)
            cell.addSubview(textField)
        } else if tableColumn == table.tableColumns[1] {
            let text = getEventLabel(pmsetAssertion.action)
            let textField = NSTextField(labelWithString: text)
            cell.addSubview(textField)
        } else if tableColumn == table.tableColumns[2] {
            let text = pmsetAssertion.name
            let textField = NSTextField(labelWithString: text)
            cell.addSubview(textField)
        }
        
        return cell
    }

    func getEventLabel(_ action: String) -> String {
        switch action {
            case "Created", "TurnedOn":
                return "Preventing sleep"
            case "Released", "TurnedOff":
                return "Lock released"
            default:
                return ""
        }
    }
}
