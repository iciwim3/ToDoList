//
//  ToDoTableViewCell.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/26/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toDoLabel: UILabel!
    
    var delegate: TodoCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func completeToDo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestComplete(self)
        }
    }
    
    @IBAction func deleteToDo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestDelete(self)
        }
    }
    
    @IBAction func shareToDo(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestShare(self)
        }
    }
    
    
}
