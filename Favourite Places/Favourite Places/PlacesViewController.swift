//
//  ViewController.swift
//  Favourite Places
//
//  Created by Lucy Rogers on 01/11/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  Student: Lucy Rogers
//  Student ID: 201078869
//  COMP327 - Mobile Computing
//  Assignment 3 - App Portfolio
//  App 4 - My Favourite Places
//

import UIKit
import CoreData

// Global
var places = [Dictionary<String, String>()]		// Array of dictionaries (of places)
var placesList = [NSManagedObject]()			// Array of NSManagedObjects
var currentPlace = -1							// Current place - pass details of currently chosen place (-1 indicates no current place chosen)

class PlacesViewController: UITableViewController {
	
	// Outlets
	@IBOutlet var placesTable: UITableView!
	
	// Core Data
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var context: NSManagedObjectContext?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Edit button added to left of nav bar
		let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit))
		self.navigationItem.leftBarButtonItem = editButton

        // Retrieve list of places from core data (if data exists)
		context = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyPlaces")
		fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "placeName", ascending: true))
		fetchRequest.returnsObjectsAsFaults = false
		do{
			let results = try context?.fetch(fetchRequest)
			if(results?.count)! > 0 {
				for i in 0..<(results?.count)! {			// For each result retrieved
					let result = results?[i] as! MyPlaces
					
					// Get the values for this place
					let placeTitle = result.placeName ?? "title"
					let placeLat = result.latitude ?? "latitude"
					let placeLon = result.longitude ?? "longitude"
					
					// Add the place to data stored (list of places and list of NSManagedObjects)
					let newPlace = ["name": placeTitle, "lat": placeLat, "lon": placeLon]
					places.append(newPlace)
					placesList.append(result)
				}
			} else {
				print("No results")						// No results in core data
			}
		} catch {
			print("Couldn't fetch results")				// Error retrieving results from core data
		}
    }
	
	// Function to delete table rows when table is in editing style
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if(editingStyle == .delete){
			context = appDelegate.persistentContainer.viewContext
			context?.delete(placesList[indexPath.row])				// Delete from context
			do {
				try context?.save()									// Save context
			} catch {
				print("Oops! An error occurred")
			}
			places.remove(at: indexPath.row)						// Delete row from data
			placesTable.deleteRows(at: [indexPath], with: .fade)	// Delete from table view (with fade)
		}
	}
	
	// Function to toggle between editing and non-editing state for table (when user clicks 'edit' button)
	@objc func toggleEdit(){
		placesTable.setEditing(!placesTable.isEditing, animated: true)
		navigationItem.leftBarButtonItem?.title = placesTable.isEditing ? "Done" : "Edit"
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if places.count == 1 && places[0].count == 0 {		// If no elements in the 'places' list
			places.remove(at: 0)
			// Add a default value
			places.append(["name":"Ashton Building", "lat": "53.406566", "lon": "-2.966531"])
			
			// Save to core data
			self.context = self.appDelegate.persistentContainer.viewContext
			let newPlace = NSEntityDescription.insertNewObject(forEntityName: "MyPlaces", into: self.context!) as! MyPlaces
			newPlace.setValue("Ashton Building", forKey: "placeName")
			newPlace.setValue("53.406566", forKey: "latitude")
			newPlace.setValue("-2.966531", forKey: "longitude")
			do {
				try self.context?.save()
			} catch {
				print("Oops! Error saving this place to core data")
			}
		}
		
		// If blank entry in places list
		if places[0].count == 0 {
			places.remove(at: 0)		// Remove this entry
		}
		
		currentPlace = -1				// No current place selected
		placesTable.reloadData()		// Reload table data

	}
	
	// Function to return how many sections in table
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1			// 1 section in table
	}
	
	// Function to return number of rows for table
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count			//  Num rows is num places
	}
	
	// Function to return cell for each row of table
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
		if (places[indexPath.row]["name"] != nil) {					// If place has a name
			cell.textLabel?.text = places[indexPath.row]["name"]	// Set cell text to be name of place
		}
		return cell													// Return cell
	}
	
	// Function to define action for when table row is selected
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		currentPlace = indexPath.row								// Set current place
		performSegue(withIdentifier: "to Map", sender: nil)			// Segue to next view (map)
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
