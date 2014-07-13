//
//  MasterViewController.swift
//  ToDo
//
//  Created by Ronald Mannak on 7/12/14.
//  Copyright (c) 2014 Ronald Mannak. All rights reserved.
//

import UIKit
import CloudKit

class MasterViewController: UITableViewController {

    var todoDatabase = CKContainer.defaultContainer().publicCloudDatabase
//    var currentUser: CKRecord
    var tasks = [CKRecord]()
    var predicate: NSPredicate
    var subscription: CKSubscription
    var username = "ronald"

    init(coder aDecoder: NSCoder!)
    {
        // Subscribe to server updates
        predicate = NSPredicate(format: "assignedTo = %@", username)
        subscription = CKSubscription(recordType: "ToDo", predicate: predicate, options: .FiresOnRecordCreation) //| .FiresOnRecordUpdate |.FiresOnRecordDeletion
        var notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "LOCAL_NOTIFICATION_KEY"
        notificationInfo.soundName = "Party.aiff"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        todoDatabase.saveSubscription(subscription) {
            (subscription: CKSubscription!, error: NSError!) in
            if error {
                println(error)
            }
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
            
        self.fetchListFromServer()
    }

    // Database
    
    func fetchListFromServer() {

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        var query = CKQuery(recordType:"ToDo", predicate: predicate)
        todoDatabase.performQuery(query, inZoneWithID: nil, completionHandler:{
            records, error in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            if error {
                println(error.localizedDescription)
            } else {
                self.tasks = records as [CKRecord]
//                records.map(<#transform: (T) -> U#>)
//                println("fetched: " + self.task)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.reloadData()
                }
            }
        
        })
    }
    
    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { textField in textField.placeholder = "Buy milk" }
        alert.addTextFieldWithConfigurationHandler { textField in textField.placeholder = "Me" }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { action in
            alert.dismissViewControllerAnimated(true, completion:{})
        }
        alert.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "OK", style: .Default) { action in

            let taskField = alert.textFields[0] as UITextField
            let assignToField = alert.textFields[1] as UITextField
            self.addTask(taskField.text, assignTo:assignToField.text)
            alert.dismissViewControllerAnimated(true) {}
        }
        alert.addAction(submitAction)
        
        presentViewController(alert, animated: true) {}
    }
    
    func addTask(task: String, assignTo:String) {
        
        var newTask = CKRecord(recordType: "ToDo")
        newTask.setObject(NSDate(), forKey: "created")
        newTask.setObject(task, forKey: "task")
        if countElements(assignTo) > 0 {
            newTask.setObject(assignTo, forKey: "assignedTo")
        } else {
            newTask.setObject(username, forKey: "assignedTo")
        }
        // UITextField always returns a String even when text is empty
//        if let assignToString = assignTo {
//            newTask.setObject(assignToString, forKey: "assignedTo")
//        } else {
//            // assign task to self
//
//        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        todoDatabase.saveRecord(newTask) {
            (CKRecord record, NSError error) in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
//            self.tasks += record
//            let indexPath = NSIndexPath(forRow: self.tasks.count - 1, inSection: 0)
//            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.fetchListFromServer()
            }
        }
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = tasks[indexPath.row]
            (segue.destinationViewController as DetailViewController).detailItem = object
        }
    }

    // #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = tasks[indexPath.row] as CKRecord
            
        if let task = object.objectForKey("task") as String? {
            cell.textLabel.text = task
        }
//        cell.textLabel.text = object.objectForKey("task") as String
            
//        if let created = object.objectForKey("createdBy") as String? {
//            cell.detailTextLabel.text = created
//        } else {
//            cell.detailTextLabel.text = ""
//        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
            self.fetchListFromServer()
    }
    
    
    @IBAction func add(sender: UIBarButtonItem) {
        self.insertNewObject(sender)
    }

}
