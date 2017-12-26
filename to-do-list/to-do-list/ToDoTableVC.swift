//
//  ToDoTableVC.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/26/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit

class ToDoTableVC: UITableViewController, TodoCellDelegate {
    
    var todoItems: [ToDoItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
       
    }

    @IBAction func addNewToDo(_ sender: Any) {
        let addAlert = UIAlertController(title: "New ToDo", message: "Enter a Title", preferredStyle: .alert)
        addAlert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "ToDo Item Title"
        }
        
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
            
            guard let title = addAlert.textFields?.first?.text else { return }
            let newToDo = ToDoItem(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
            newToDo.saveItem()
            
            self.todoItems.append(newToDo)
            
            let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
            
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.present(addAlert, animated: true, completion: nil)
        
    }
    
    func didRequestComplete(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            var todoItem = todoItems[indexPath.row]
            todoItem.markAsCompleted()
            cell.toDoLabel.attributedText = strikeThroughText(todoItem.title)
        }
    }
    
    func strikeThroughText(_ text: String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    func didRequestDelete(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            todoItems[indexPath.row].deleteItem()
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func loadData() {
        todoItems = [ToDoItem]()
        todoItems = DataManager.loadAll(ToDoItem.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoTableViewCell
        cell.delegate = self
        
        let todoItem = todoItems[indexPath.row]
        
        cell.toDoLabel.text = todoItem.title
        
        if todoItem.completed {
            cell.toDoLabel.attributedText = strikeThroughText(todoItem.title)
        }

        return cell
    }

}
