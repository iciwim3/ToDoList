//
//  ContainerVC.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/28/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var todoTableViewController: ToDoTableVC! 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.containerVC2TodoVC {
            todoTableViewController = (segue.destination as! UINavigationController).childViewControllers.first as! ToDoTableVC
            todoTableViewController.connectionButtonReference = connectionButton
        }
    }
    
    @IBAction func addNewTodoItem(_ sender: Any) {
        todoTableViewController.addNewToDo()
    }
    
    @IBAction func triggerConnection(_ sender: Any) {
        todoTableViewController.showConnectivityButtonTapped()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct Storyboard {
        static let containerVC2TodoVC = "TodoVC"
    }

}
