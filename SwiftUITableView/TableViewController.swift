//
//  TableViewController.swift
//  SwiftUITableView
//
//  Created by cpahull on 15/11/2020.
//

import Cocoa
import Combine
import SwiftUI

let newRowSelected = NotificationCenter.default // Notification to prompt SwiftUI to update selectedRow
    .publisher(for: Notification.Name("newRowSelected"))
    .map { notification in
        return notification.userInfo as! [String: Int]
    }

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var contents: [[String]]?

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return contents?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView
        view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        view.textField?.stringValue = contents?[row][Int(tableColumn!.identifier.rawValue)!] ?? "None"
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let newRowSelected = ["": tableView.selectedRow]
        NotificationCenter.default.post(name: Notification.Name("newRowSelected"), object: self, userInfo: newRowSelected)
    }

    func setContents(names: [[String]]) -> Void {
        contents = names
        tableView.reloadData()
    }
    
    func setSelectedRow(selectedRow: Int) -> Void {
        tableView.selectRowIndexes([selectedRow], byExtendingSelection: false)
    }
    
    func getSelectedRow() -> Int {
        return tableView.selectedRow
    }
}

