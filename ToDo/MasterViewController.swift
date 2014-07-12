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
//    var currentUser = CKRecord
    var tasks = [CKRecord]()
    
    var myString: String {
        get {
            return "test"
        }
        set {
            self.myString = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { textField in textField.placeholder = "Buy milk" }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { action in
            alert.dismissViewControllerAnimated(true, completion:{})
        }
        alert.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "OK", style: .Default) { action in

            let textField = alert.textFields[0] as UITextField
            self.addTask(textField.text)
            alert.dismissViewControllerAnimated(true) {}
        }
        alert.addAction(submitAction)
        
        presentViewController(alert, animated: true) {}
    }
    
    func addTask(task: String) {
        
        var newTask = CKRecord(recordType: "ToDo")
        newTask.setObject(task, forKey: "task")
        todoDatabase.saveRecord(newTask) {
            (CKRecord record, NSError error) in
            self.tasks += record
            let indexPath = NSIndexPath(forRow: self.tasks.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

        }
//        todoDatabase.saveRecord(newTask) {
//            CKRecord record in
//            
//        }
//        newTask["task"] = task
//        tasks += task
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

        let object = tasks[indexPath.row]
        cell.textLabel.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tasks.removeAtIndex(indexPath.row)
//            objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
