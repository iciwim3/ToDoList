//
//  TodoCellDelegate.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/26/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import UIKit

protocol TodoCellDelegate {
    func didRequestDelete(_ cell: ToDoTableViewCell)
    func didRequestComplete(_ cell: ToDoTableViewCell)
}
