//
//  ToDoTableVC.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/26/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ToDoTableVC: UITableViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var todoItems: [ToDoItem]! {
        didSet {
            progressBar.setProgress(progress, animated: true)
        }
    }
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progress: Float {
        if todoItems.count > 0 {
            return Float(todoItems.filter({$0.completed}).count) / Float(todoItems.count)
        } else {
            return 0
        }
    }
    
    var connectionButtonReference: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectivity()
        loadData()
    }
    
    func setupConnectivity() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }

    func addNewToDo() {
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
    
    func completeTodoItem(_ indexPath: IndexPath) {
        var todoItem = todoItems[indexPath.row]
        todoItem.markAsCompleted()
        todoItems[indexPath.row] = todoItem
        
        if let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell {
            cell.toDoLabel.attributedText = strikeThroughText(todoItem.title)
            
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = cell.transform.scaledBy(x: 1.5, y: 1.5)
            }, completion: { (success) in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        }
        
    }
    
    func showConnectivityButtonTapped() {
        let actionSheet = UIAlertController(title: "ToDo Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ske-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "ske-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func strikeThroughText(_ text: String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    /*
    func didRequestDelete(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            todoItems[indexPath.row].deleteItem()
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
 
    func didRequestShare(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let todoItem = todoItems[indexPath.row]
            
            sendTodo(todoItem)
        }
    }
    */
    
    func sendTodo(_ todoItem: ToDoItem) {
        if mcSession.connectedPeers.count > 0 {
            if let todoData = DataManager.loadData(todoItem.itemIdentifier.uuidString) {
                do {
                    try mcSession.send(todoData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    fatalError("Could not send todo item")
                }
            }
        } else {
            showConnectivityButtonTapped()
        }
    }
    
    func loadData() {
        todoItems = [ToDoItem]()
        todoItems = DataManager.loadAll(ToDoItem.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        tableView.reloadData()
        
        progressBar.setProgress(progress, animated: true)
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
        
        let todoItem = todoItems[indexPath.row]
        
        cell.toDoLabel.text = todoItem.title
        
        if todoItem.completed {
            cell.toDoLabel.attributedText = strikeThroughText(todoItem.title)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: .normal, title: "Share") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let todoItem = self.todoItems[indexPath.row]
            self.sendTodo(todoItem)
        }
        shareAction.backgroundColor = UIColor(named: "mainBlueColor")
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            self.todoItems[indexPath.row].deleteItem()
            self.todoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = UIColor(named: "mainYellowColor")
        
        return [deleteAction, shareAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completeTodoItem(indexPath)
    }
    
    // MARK: Multipeer Connectivity Delegate Functions
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            DispatchQueue.main.sync {
                self.connectionButtonReference.setTitle("Connected", for: .normal)
            }
            
        case MCSessionState.connecting:
            DispatchQueue.main.sync {
                self.connectionButtonReference.setTitle("Connecting", for: .normal)
            }
            
        case MCSessionState.notConnected:
            DispatchQueue.main.sync {
                self.connectionButtonReference.setTitle("Offline", for: .normal)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let todoItem = try JSONDecoder().decode(ToDoItem.self, from: data)
            DataManager.save(todoItem, with: todoItem.itemIdentifier.uuidString)
            
            DispatchQueue.main.async {
                self.loadData()
            }
            
        } catch {
            fatalError("Unable to process the received data")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Don't need
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Don't need
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Don't need
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }

}
