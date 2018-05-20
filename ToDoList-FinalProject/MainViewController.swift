//
//  MainViewController.swift
//  ToDoList-FinalProject
//
//  Created by shadi on 5/20/18.
//  Copyright © 2018 shadi Zaqout. All rights reserved.
//

import UIKit
import CoreData

var taskArray = [TaskClass]()
var completedTaskArray = [TaskClass]()
var storedTaskData = [NSManagedObject]()

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var taskTable: UITableView!
    var isNewTask : Bool?
    @IBOutlet weak var taskTextField: UITextField!
    
    @IBOutlet weak var quickAddButton: UIButton!
    @IBOutlet weak var toDetailsButton: UIButton!
    
    var lastSelectedIndex: Int?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.taskTable.dataSource = self
        self.taskTable.delegate = self
        self.taskTextField.delegate = self
        
        taskTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let nib = UINib(nibName: "TaskCellVC", bundle: nil)
        taskTable.register(nib, forCellReuseIdentifier: "TaskCell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        self.view.addGestureRecognizer(longGesture)
        
        quickAddButton.isEnabled = false
        quickAddButton.alpha = 0.5
        
        retrieveCoreData()
        
        if splitViewController?.preferredDisplayMode == .allVisible {
            toDetailsButton.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //updateDisplayOrder()
        taskTable.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let mangedContext = appDelegate.persistentContainer.viewContext
        
        //fetch Tasks from Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            let results = try mangedContext.fetch(fetchRequest)
            storedTaskData = results as! [NSManagedObject]
        }catch let error as NSError {
            print("Feting error: \(error.userInfo)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as? TaskCellVC!
        cell?.taskLabel.text = taskArray[indexPath.row].taskString
        
        
        if taskArray[indexPath.row].dueDate != nil {
            cell?.dateLabel.text = taskArray[indexPath.row].dueDate?.toString(dateFormat: "MM-dd")
        }else{
            cell?.dateLabel.text = " "
        }
        
        if taskArray[indexPath.row].isTaskCompleted == false {
            cell?.checkBoxButton.setImage(#imageLiteral(resourceName: "openCheckBox"), for: .normal)
        }else{
            cell?.checkBoxButton.setImage(#imageLiteral(resourceName: "checkedBox"), for: .normal)
        }
        
        cell?.checkBoxButton.tag = indexPath.row
        cell?.checkBoxButton.addTarget(self, action: #selector(checkBoxTapped(sender:)), for: .touchUpInside)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            taskArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            deleteRecord(index: indexPath.row)
            taskTable.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndex = indexPath.row
        self.performSegue(withIdentifier: "showOldTaskDetails", sender: taskArray[indexPath.row])
        
    }
    
    
    //add a task without going to details page
    @IBAction func quickAddTapped(_ sender: Any) {
        
        if taskTextField.text != "" {
            let newTask = TaskClass(taskString: taskTextField.text!)
            newTask.displayOrder = taskArray.count
            taskArray.append(newTask)
            print(taskArray.count)
            saveToCoreData(task: newTask)
            
            taskTable.beginUpdates()
            taskTable.insertRows(at: [IndexPath(row: taskArray.count-1, section: 0)], with: .automatic)
            taskTable.endUpdates()
            taskTextField.text = ""
            quickAddButton.isEnabled = false
            
        }
    }
    
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        isNewTask = true
        self.performSegue(withIdentifier: "newDetailsTask", sender: isNewTask!)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newDetailsTask" {
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? DetailsViewController {
                    let isNewTask = sender as? Bool
                    childVC.isNewTask = isNewTask
                }
                
            }
        }
        
        if segue.identifier == "showOldTaskDetails" {
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? DetailsViewController {
                    childVC.task = sender as? TaskClass
                    childVC.isNewTask = false
                    childVC.taskIndex = lastSelectedIndex
                }
            }
            
        }
        
    }
    
    
    
    @objc func checkBoxTapped(sender: UIButton) {
        if taskArray[sender.tag].isTaskCompleted == true {
            taskArray[sender.tag].isTaskCompleted = false
        }else{
            taskArray[sender.tag].isTaskCompleted = true
        }
        let indexPath = IndexPath(item: sender.tag, section: 0)
        taskTable.reloadRows(at: [indexPath], with: .none)
        
        print("check box indexpaht.row = \(indexPath.row)")
        print("check box sender = \(sender.tag)")
        
        
        storedTaskData[indexPath.row].setValue(taskArray[indexPath.row].isTaskCompleted, forKey: "isTaskCompleted")
        appDelegate.saveContext()
        
    }
    
    @objc func tap(gesture: UITapGestureRecognizer){
        taskTextField.resignFirstResponder()                            //for keyboard
        
        //can select different tasks and see their details on right side of split view
        if splitViewController?.preferredDisplayMode == .allVisible {
            let navVC: UINavigationController =  self.splitViewController!.viewControllers[1] as! UINavigationController
            let sectionsVC : DetailsViewController = navVC.topViewController as! DetailsViewController
            
            if let indexPath = self.taskTable.indexPathForSelectedRow{
                taskTable.deselectRow(at: indexPath, animated: true)
            }
            
            sectionsVC.setupForNewTask()
            
        }
        
        
    }
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        
        let longPress = gesture as UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: taskTable)
        var indexPath = taskTable.indexPathForRow(at: locationInView)
        
        
        //swapping cells by long tap and drag
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        switch state {
            
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath as NSIndexPath?
                let cell = taskTable.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot = snapshopOfCell(inputView: cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                taskTable.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        case UIGestureRecognizerState.changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath?.row != nil)) {
                taskTable.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                swap(&taskArray[indexPath!.row], &taskArray[indexPath!.row])
                
                Path.initialIndexPath = indexPath as NSIndexPath?
                //updateDisplayOrder()
                taskTable.reloadData()
            }
        default:
            let cell = taskTable.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = .identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
            
        }
    }
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        // cellSnapshot.layer.shadowOffset = CGRect(origin: (-5.0, 0.0), size: 0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    //conform to UITextField Delegate
    func textFieldDidBeginEditing(textField: UITextField!) {}
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textFieldDidEndEditing(_ textField: UITextField) {}
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    //don't allow blank task to be added
    @objc func textFieldDidChange(_ textField: UITextField) {
        if taskTextField.text == "" {
            quickAddButton.isEnabled = false
            quickAddButton.alpha = 0.5
        }else{
            quickAddButton.isEnabled = true
            quickAddButton.alpha = 1.0
        }
        
    }
    //retrieve tasks and add to table
    func retrieveCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            storedTaskData = results as! [NSManagedObject]
            if storedTaskData.isEmpty == false {
                for i in 0..<storedTaskData.count {
                    
                    let taskString = storedTaskData[i].value(forKey: "taskString") as? String
                    let isTaskCompleted = storedTaskData[i].value(forKey: "isTaskCompleted") as? Bool
                    let retrievedTask = TaskClass(taskString: taskString!)
                    retrievedTask.isTaskCompleted = isTaskCompleted
                    if let dueDate = storedTaskData[i].value(forKey: "dueDate") as? Date {
                        retrievedTask.dueDate = dueDate
                    }else{
                        print("no DATE")
                    }
                    taskArray.append(retrievedTask)
                    
                }
                taskTable.reloadData()
                
            }
        }catch _ as NSError {
            print("FETCHING ERROR")
            
        }
    }
    func saveToCoreData(task : TaskClass){
        let context = appDelegate.persistentContainer.viewContext
        //first insert new managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        let taskToSave = NSManagedObject(entity: entity!, insertInto: context)
        let taskString = task.taskString
        let taskPosition = task.displayOrder
        //add values for attributes of the entity
        taskToSave.setValue(taskString, forKey: "taskString")
        taskToSave.setValue(false, forKey: "isTaskCompleted")
        taskToSave.setValue(taskPosition, forKey: "displayOrder")
        storedTaskData.append(taskToSave)
        //updateDisplayOrder()
        //save to disk
        appDelegate.saveContext()
    }
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func deleteRecord(index : Int){
        let persContainer = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let result = try? persContainer.fetch(fetchRequest)
        persContainer.delete(storedTaskData[index])
        do {
            try persContainer.save()
            //updateDisplayOrder()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
        }
    }
    func reloadTableFromSplit(){
        taskTable.reloadData()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
}






