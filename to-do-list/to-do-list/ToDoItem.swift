//
//  ToDoItem.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/24/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import Foundation

struct ToDoItem : Codable {
    
    var title: String
    var completed: Bool
    var createdAt: Date
    var itemIdentifier: UUID
    
    func saveItem() {
        DataManager.save(self, with: itemIdentifier.uuidString)
    }
    
    func deleteItem() {
      DataManager.delete(itemIdentifier.uuidString)
    }
    
    mutating func markAsCompleted() {
        self.completed = true
        DataManager.save(self, with: itemIdentifier.uuidString)
    }
    
}
