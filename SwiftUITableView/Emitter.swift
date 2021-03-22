//
//  Emitter.swift
//  SwiftUITableView
//
//  Created by Adam Horacek on 2021-03-21.
//

import Foundation
import Combine

class Emitter: ObservableObject {
    
    private let newItemPublisher = CurrentValueSubject<Item, Never>(Item(name: "Default Item", cleared: false))
    private let indexSetToRemovePublisher = CurrentValueSubject<IndexSet, Never>(IndexSet())
    
    var newItems: AnyPublisher<[Item], Never>
    
    var indexSetToRemove: AnyPublisher<IndexSet, Never>
    
    var cancellBag = Set<AnyCancellable>()
    
    init() {
        newItems = newItemPublisher
            .collect(.byTime(RunLoop.main, 1.0))
            .eraseToAnyPublisher()
        
        indexSetToRemove = indexSetToRemovePublisher
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func start() {
        let timer1 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let randomInteger = Int.random(in: 0..<65535)
            
            for _ in 0..<100 {
                let item = Item(name: "Inserted \(randomInteger)", cleared: true)
                self.newItemPublisher.send(item)
            }
        }
        RunLoop.current.add(timer1, forMode: .common)
        
        let timer2 = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            var indexSet = IndexSet()
            
            for _ in 0..<5000 {
                let randomInteger = Int.random(in: 0..<65535)
                indexSet.insert(randomInteger)
            }
            
            self.indexSetToRemovePublisher.send(indexSet)
        }
        RunLoop.current.add(timer2, forMode: .common)
    }
    
}
