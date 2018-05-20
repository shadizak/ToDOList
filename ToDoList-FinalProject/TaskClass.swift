//
//  TaskClass.swift
//  ToDoList-FinalProject
//
//  Created by shadi on 5/20/18.
//  Copyright © 2018 shadi Zaqout. All rights reserved.
//

import Foundation



class TaskClass {
    
    var taskString : String?
    var dueDate : Date?
    var isTaskCompleted : Bool?
    var taskCategory : String?
    var displayOrder: Int?
    
    init (taskString : String){
        self.taskString = taskString
        isTaskCompleted = false
        
    }
    
}


extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

