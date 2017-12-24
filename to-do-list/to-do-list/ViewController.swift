//
//  ViewController.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/24/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toDoItem = ToDoItem(title: "Wrap gifts", completed: false, createdAt: Date(), itemIdentifier: UUID())
        
        let todos = DataManager.loadAll(ToDoItem.self)
        
        print(todos)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

