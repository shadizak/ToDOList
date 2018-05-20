//
//  DetailsViewController.swift
//  ToDoList-FinalProject
//
//  Created by shadi on 5/20/18.
//  Copyright © 2018 shadi Zaqout. All rights reserved.
//

import UIKit
import CoreData
class DetailsViewController: UIViewController  {
    
    
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var isNewTask : Bool?
    var taskIndex : Int?
    var task : TaskClass?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let mainVC = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        setUpLayouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isNewTask == false {
            setUpOldTask()
        }else{
            isNewTask = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let myTaskString = taskDescriptionTextView.text
        let dueDate = taskDatePicker.date
        
        if isNewTask == true {
            let newTask = TaskClass(taskString: myTaskString!)
            newTask.dueDate = dueDate
            
            taskArray.append(newTask)
            saveToCoreData(task: newTask)
            
        }else{
            let newTask = TaskClass(taskString: myTaskString!)
            newTask.dueDate = dueDate
            taskArray[taskIndex!] = newTask
            updateTaskInCoreData(task: newTask)
            
        }
        
        if splitViewController?.preferredDisplayMode == .allVisible {
            let navVC: UINavigationController =  self.splitViewController!.viewControllers[0] as! UINavigationController
            let sectionsVC : MainViewController = navVC.topViewController as! MainViewController
            sectionsVC.taskTable.reloadData()
            taskDescriptionTextView.text = ""
            isNewTask = true
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    @objc func tap(gesture: UITapGestureRecognizer) {
        taskDescriptionTextView.resignFirstResponder()
    }
    
    func setUpLayouts(){
        taskDescriptionTextView.layer.borderWidth = 1.0
        taskDescriptionTextView.layer.borderColor = UIColor.gray.cgColor
        taskDescriptionTextView.layer.cornerRadius = 10.0
        if splitViewController?.preferredDisplayMode == .allVisible {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    
    func setUpOldTask(){
        taskDescriptionTextView.text = task?.taskString
        if task?.dueDate != nil {
            taskDatePicker.date = (task?.dueDate)!
        }
    }
    
    func saveToCoreData(task: TaskClass){
        let context = appDelegate.persistentContainer.viewContext
        
        if isNewTask == true {
            
            //first insert new managed object context
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
            let taskToSave = NSManagedObject(entity: entity!, insertInto: context)
            
            let taskString = task.taskString
            let taskDate = task.dueDate
            let isTaskCompleted = task.isTaskCompleted
            
            
            //add values for attributes of the entity
            taskToSave.setValue(taskString, forKey: "taskString")
            taskToSave.setValue(taskDate, forKey: "dueDate")
            taskToSave.setValue(isTaskCompleted, forKey: "isTaskCompleted")
            storedTaskData.append(taskToSave)
            
            //save to disk
            appDelegate.saveContext()
            
        }
    }
    
    func updateTaskInCoreData(task: TaskClass){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        storedTaskData[taskIndex!].setValue(task.taskString, forKey: "taskString")
        storedTaskData[taskIndex!].setValue(task.dueDate, forKey: "dueDate")
        storedTaskData[taskIndex!].setValue(task.isTaskCompleted, forKey: "isTaskCompleted")
        appDelegate.saveContext()
        
    }
    
    
    func setupForNewTask(){
        taskDescriptionTextView.text = ""
        isNewTask = true
        
    }
    
}
