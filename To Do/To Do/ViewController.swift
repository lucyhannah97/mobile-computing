//
//  ViewController.swift
//  To Do
//
//  Created by Lucy Rogers on 25/10/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  Student: Lucy Rogers
//  Student ID: 201078869
//  COMP327 - Mobile Computing
//  Assignment 3 - App Portfolio
//  App 3 - To Do List
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	// Outlets
	@IBOutlet weak var inputField: UITextField!
	@IBOutlet weak var listTable: UITableView!
	@IBOutlet weak var navBar: UINavigationBar!
	
	// Lists
	var list: [String] = []
	var todo_list = [NSManagedObject]()
	
	// Core Data
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var context: NSManagedObjectContext?

	override func viewDidLoad() {
		super.viewDidLoad()
		inputField.clearButtonMode = .always			// Enable 'X' button to allow field to be quickly cleared
		inputField.clearsOnBeginEditing = true			// Input field is cleared when user begins editing
		
		// Edit button added to left of nav bar
		let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit))
		self.navigationItem.leftBarButtonItem = editButton
		
		// Clear button added to right of nav bar
		let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTable))
		self.navigationItem.rightBarButtonItem = clearButton
		
		// Retrieve list from core data (if list exists in core data)
		context = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDos")
		fetchRequest.predicate = NSPredicate(format: "todo <> %@", "")
		fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "todo", ascending: true))
		fetchRequest.returnsObjectsAsFaults = false
		do{
			let results = try context?.fetch(fetchRequest)
			if(results?.count)! > 0 {
				for i in 0..<(results?.count)! {
					let result = results?[i] as! ToDos
					if let theToDo = result.todo {				// Add 'to do item' to lists
						list.append(theToDo)
						todo_list.append(result)
					}
				}
			} else {
				print("No results")
			}
		} catch {
			print("Couldn't fetch results")
		}
	}
	
	// When 'add' button is pressed - add new item to list
	@IBAction func addButton(_ sender: UIButton) {
		guard let toDoItem = inputField.text else {return}		// To do item is value entered by user
		list.append(toDoItem)									// Add to do item to list
		let newToDo = NSEntityDescription.insertNewObject(forEntityName: "ToDos", into: context!) as! ToDos
		newToDo.setValue(toDoItem, forKey: "todo")				// Save to do item to core data
		do{
			try context?.save()
		} catch{
			print("Oops! There was an error saving this list item")
		}
		inputField.resignFirstResponder();				// Hide keyboard
		listTable.reloadData();							// Reload table data
	}
	
	// Function to determine number of rows for table
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return list.count		// Number of rows is number of items in list
	}
	
	// Function to return the cell for each row
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "tableCell")
		let listItem = list[indexPath.item]			// String to store 'to do item'
		cell.textLabel?.text = listItem				// Set text of cell to the 'to do item'
		return cell									// Return the cell
	}
	
	// Function to delete table rows when table is in editing style
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if(editingStyle == .delete){
			list.remove(at: indexPath.row)									// Delete row from data
			context = appDelegate.persistentContainer.viewContext
			context?.delete(todo_list[indexPath.row] as NSManagedObject)	// Delete from context
			do {
				try context?.save()											// Save context
			} catch {
				print("Oops! An error occurred")
			}
			todo_list.remove(at: indexPath.row)								// Delete from core data
			listTable.deleteRows(at: [indexPath], with: .fade)				// Delete from table view (with fade)
		}
	}
	
	// Function to toggle between editing and non-editing state for table (when user clicks 'edit' button)
	@objc func toggleEdit(){
		listTable.setEditing(!listTable.isEditing, animated: true)
		navigationItem.leftBarButtonItem?.title = listTable.isEditing ? "Done" : "Edit"
		navigationItem.rightBarButtonItem?.title = listTable.isEditing ? "" : "Clear"
	}

	// Function to delete all items from the to do list (when user clicks 'clear list' button)
	@objc func clearTable(){
		// Add alert to check user wants to complete this action
		let alert = UIAlertController(title: "Clear List", message: "Are you sure you want to delete all items in the list?", preferredStyle: .alert)
		// Add 'clear' option to alert - list is then deleted
		alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { action in
			switch action.style{
			case .default:
				print("default")
				
			case .cancel:
				print("cancel")
				
			case .destructive:
				print("destructive")
				self.list.removeAll();			// Remove all elements from list
				self.deleteList()				// Method call (Clears todo list from core data)
				self.listTable.reloadData()		// Reload table
			}}))
		// Add 'cancel' option to alert - list remains the same
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	// Function to delete all items in to do list from core data
	func deleteList(){
		context = appDelegate.persistentContainer.viewContext
		let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDos")
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
		do {
			try context!.execute(deleteRequest)			// Execute delete request
			try context!.save()							// Save
		} catch {
			print("Oops! There was an error")
		}
	}
}
