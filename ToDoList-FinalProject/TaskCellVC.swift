//
//  TaskCellVC.swift
//  ToDoList-FinalProject
//
//  Created by shadi on 5/20/18.
//  Copyright © 2018 shadi Zaqout. All rights reserved.
//

import UIKit

class TaskCellVC: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func checkBoxTapped(_ sender: Any) {
        if checkBoxButton.imageView?.image == #imageLiteral(resourceName: "openCheckBox"){
            checkBoxButton.setImage(#imageLiteral(resourceName: "checkedBox"), for: .normal)
        }else{
            checkBoxButton.setImage(#imageLiteral(resourceName: "openCheckBox"), for: .normal)
        }
    }
}


