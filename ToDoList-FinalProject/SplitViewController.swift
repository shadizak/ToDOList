//
//  SplitViewController.swift
//  ToDoList-FinalProject
//
//  Created by shadi on 5/20/18.
//  Copyright © 2018 shadi Zaqout. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        self.preferredDisplayMode = .allVisible     //keep splitview always visible on iPad
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
}


