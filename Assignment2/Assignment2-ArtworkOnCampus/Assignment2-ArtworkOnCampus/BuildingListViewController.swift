//
//  BuildingListViewController.swift
//  Assignment2-ArtworkOnCampus
//
//  Created by Lucy Rogers on 10/12/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  Student: Lucy Rogers
//  Student ID: 201078869
//  COMP327 - Mobile Computing
//  Assignment 2 - Artwork On Campus
//

import UIKit

class BuildingListViewController: UITableViewController {
	
	// Variables used
	var buildingName = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = buildingName
	}
	
	// Function to determine number of rows
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return number of artworks for the building being displayed
		return artworkByBuilding[buildingName]!.count
	}
	
	// Function to determine the cell for each row
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Cell style is subtitle to include the art title and artist
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "tableCell")
		// This is the section of the table the cell is in (used to simplify later statements)
		let tableSection = buildingName
		// This is the title of the artwork
		cell.textLabel?.text = artworkByBuilding[tableSection]![indexPath.row].title
		// This is the artist of the artwork
		cell.detailTextLabel?.text = artworkByBuilding[tableSection]![indexPath.row].artist
		return cell
	}
	
	// Function for when user clicks on row in table - opens detail view controller for that piece of artwork
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Instantiate new DetailViewController
		let newView = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
		self.navigationController?.pushViewController(newView!, animated: true)
		
		// Section of table this cell is in - used to simplify later statements
		let tableSection = buildingName
		
		// Set the values for the new view
		newView!.artTitle = artworkByBuilding[tableSection]![indexPath.item].title
		newView!.artImage = artworkByBuilding[tableSection]![indexPath.item].fileName
		newView!.artist = artworkByBuilding[tableSection]![indexPath.item].artist
		newView!.artYear = artworkByBuilding[tableSection]![indexPath.item].yearOfWork
		newView!.artInfo = artworkByBuilding[tableSection]![indexPath.item].Information
	}
}
