//
//  ContentView.swift
//  SwiftUITableView
//
//  Created by cpahull on 14/11/2020.
//

import Foundation
import SwiftUI
import AppKit

class Item: NSObject, Identifiable {
    
    @objc var id: String = "\(Int.random(in: 0..<65535))"
    @objc var name: String
    @objc var cleared: Bool
    
    init(name: String, cleared: Bool) {
        self.name = name
        self.cleared = cleared
    }
    
}

struct ContentView: View {

    @ObservedObject var emitter: Emitter
        
    @State var items = [Item]()
    @State private var rowSelected = -1
    @State private var selectedName = ""
    @State private var selectedRef: String? = nil
    @State private var selectedCleared = false
    
    var body: some View {
        HSplitView {
            VStack {
                HStack {
                    Button("Clear") {
                        items.removeAll()
                        rowSelected = -1
                    }
                    .disabled(items.count == 0)
                    
                    Button("Populate") {
                        items = getitems()
                        rowSelected = items.count - 1
                        selectedRef = items[rowSelected].id
                        selectedName = items[rowSelected].name
                        selectedCleared = items[rowSelected].cleared
                    }
                    .disabled(items.count > 0)
                    
                    Button("Delete") {
                        items.remove(at: rowSelected)
                        rowSelected = -1
                    }
                    .disabled(rowSelected == -1)
                }
                
                Table(items: $items,
                      rowSelected: $rowSelected,
                      selectedName: $selectedName,
                      selectedCleared: $selectedCleared)
                    .frame(minWidth: 450, minHeight: 200)
                    .onAppear(perform: {
                        items = getitems()
                        emitter.start()
                    })
                
                HStack {
                    if rowSelected >= 0 {
                        Text(selectedName)
                        Text(items[rowSelected].id)
                        Text(selectedCleared == true ? "True" : "False")
                    }
                    else {
                        Text("None")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onReceive(emitter.newItems) { newItems in
            guard !items.isEmpty else { return }

            let random = Int.random(in: 0..<items.count)
            items.insert(contentsOf: newItems, at: random)
            
            print("Added: Date(): \(Date()), count: \(newItems.count), rows: \(items.count)")
        }
        .onReceive(emitter.indexSetToRemove) { indexSetToRemove in
            guard !items.isEmpty else { return }
            
            items.remove(atOffsets: indexSetToRemove)
            
            print("Removed: Date(): \(Date()), count: \(indexSetToRemove.count), rows: \(items.count)")
        }
    }
}

struct Table: NSViewControllerRepresentable {
    
    @Binding var items: [Item]
    @Binding var rowSelected: Int
    @Binding var selectedName: String
    @Binding var selectedCleared: Bool
    
    func makeNSViewController(context: Context) -> NSViewController {
        let tableViewController = TableViewController()
        return tableViewController
    }
        
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        guard let tableViewController = nsViewController as? TableViewController else { return }
        
        tableViewController.setContents(items: items)
        tableViewController.tableView?.delegate = context.coordinator
        
        guard rowSelected >= 0 else {
            tableViewController.arrayController.removeSelectionIndexes([0])
            return
        }
        
        tableViewController.arrayController.setSelectionIndex(rowSelected)
        tableViewController.tableView.scrollRowToVisible(rowSelected)
    }
    
    class Coordinator: NSObject, NSTableViewDelegate {
        
        var parent: Table
        
        init(_ parent: Table) {
            self.parent = parent
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            guard let tableView = notification.object as? NSTableView else { return }
            guard self.parent.items.count > 0 else { return }
            guard tableView.selectedRow >= 0 else {
                self.parent.rowSelected = -1
                return
            }
            
            self.parent.rowSelected = tableView.selectedRow
            self.parent.selectedName = self.parent.items[tableView.selectedRow].name
            self.parent.selectedCleared = self.parent.items[tableView.selectedRow].cleared
        }

        @IBAction func nameCellEdited(_ sender: Any) {
            guard let textView = sender as? NSTextField else { return }
            self.parent.selectedName = textView.stringValue
        }
        
        @IBAction func clearedCellToggled(_ sender: Any) {
            guard self.parent.rowSelected >= 0 else { return }
            self.parent.selectedCleared = self.parent.items[self.parent.rowSelected].cleared
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

}

func getitems() -> [Item] {
    var array: [Item] = []
    
    for index in 0...100000 {
        array.append(Item(name: "Original \(index)", cleared: false))
    }
    
    return array
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(emitter: Emitter())
    }
    
}
