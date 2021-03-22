//
//  TableViewController.swift
//  SwiftUITableView
//
//  Created by cpahull on 15/11/2020.
//

import Foundation
import Cocoa

class TableViewController: NSViewController {
    
    @objc dynamic var contents: [Item] = []

    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    @IBAction func nameCellEdited(_ sender: Any) { }
    
    @IBAction func clearedCellToggled(_ sender: Any) { }

    func setContents(items: [Item]) -> Void {
        contents = items
    }
    
    // NOTE: - Not sure if this really helps...
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = false
        clipView.wantsLayer = true
        scrollView.wantsLayer = true
        tableView.wantsLayer = false
    }
    
}

