//
//  ViewController.swift
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
import MapKit
import CoreData
import CoreLocation

struct artPiece: Decodable {
	let id: String
	let title: String
	let artist: String
	let yearOfWork: String
	let Information: String
	let lat: String
	let long: String
	let location: String
	let locationNotes: String
	let fileName: String
	let lastModified: String
	let enabled: String
}

struct artworks: Decodable {
	let artworks2: [artPiece]
}

struct building: Decodable {
	let name: String
	let lat: String
	let long: String
}

var artworkByBuilding = [String: [artPiece]]()		// Dictionary of art pieces

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
	
	// Arrays of buildings (filteredBuildings is used for when the user filters using the search bar)
	var buildings = [building]()
	var filteredBuildings = [building]()

	// Location Manager & user location
	let locationManager = CLLocationManager()
	var userLocation = CLLocationCoordinate2D()
	
	// Core Data
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var context: NSManagedObjectContext?
	
	// Search Bar
	let searchController = UISearchController(searchResultsController: nil)
	
	// Outlets
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var table: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup the search controller
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search for a building..."
		navigationItem.searchController = searchController
		definesPresentationContext = true
		
		// Decode JSON
		if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artworksOnCampus/data.php?class=artworks2&lastUpdate=2017-11-01"){
			let session = URLSession.shared
			session.dataTask(with: url) { (data, response, err) in
				guard let jsonData = data else {
					return
				}
				do {
					let decoder = JSONDecoder()
					let artList = try decoder.decode(artworks.self, from: jsonData)
					// For each piece
					for anArtPiece in artList.artworks2 {
						// If location exists as key in dictionary, append art piece
						if(artworkByBuilding[anArtPiece.location] != nil){
							artworkByBuilding[anArtPiece.location]!.append(anArtPiece)
						}
						else {	// Location not already present in dictionary
							// Add new dictionary key for this location
							artworkByBuilding[anArtPiece.location] = [anArtPiece]
							// Add this location to the list of possible buildings
							let newBuilding = building(name: anArtPiece.location, lat: anArtPiece.lat, long: anArtPiece.long)
							self.buildings.append(newBuilding)
						}
					}
					
					// Sort buildings in order of proximity
					self.sortBuildings()
					
					// Load map
					self.loadMap()
					
					// Reload table data
					DispatchQueue.main.async { [unowned self] in
						self.table.reloadData()
					}
				} catch let jsonErr {				// Catch & print error
					print("Error decoding JSON, ", jsonErr)
				}
			}.resume()
		}
	}
	
	// Function for when the view appears - reload table & map
	override func viewDidAppear(_ animated: Bool) {
		table.reloadData()
		map.reloadInputViews()
	}
	
	// Function to determine whether the search bar is empty
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	// Function to update search results
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	// Function to filter the buildings array by the string entered by the user in the search bar, and store results in the filtered buildings array
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredBuildings = buildings.filter({( building : building) -> Bool in
			return building.name.lowercased().contains(searchText.lowercased())
		})
		
		// Reload table
		table.reloadData()
	}
	
	// Function to determine if the user is filtering the table (using the search bar)
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
	// Function to sort buildings in order of proximity to user's location
	func sortBuildings(){
		// Get user's current location
		//let userCoord = CLLocation(latitude: 53.406566, longitude: -2.966531)
		let userCoord = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
		
		// Sort the buildings array in order of proximity from the user's location
		buildings = buildings.sorted{
			let distance1 = CLLocation(latitude: Double($0.lat)!, longitude: Double($0.long)!)
			let distance2 = CLLocation(latitude: Double($1.lat)!, longitude: Double($1.long)!)
			if (userCoord.distance(from: distance1)) != (userCoord.distance(from: distance2)){
				return userCoord.distance(from: distance1) < (userCoord.distance(from: distance2))
			}
			else {
				return userCoord.distance(from: distance1) > (userCoord.distance(from: distance2))
			}
		}
	}
	
	// Function to load the map and centre it around the user's current coordinates
	func loadMap() {
		locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
		}
		map.delegate = self
		map.isZoomEnabled = true
		map.isScrollEnabled = true
		
		DispatchQueue.main.async { [unowned self] in
			// For each building, add an annotation to the map
			for aBuilding in self.buildings {
				self.addAnnotation(name: aBuilding.name, latitude: Double(aBuilding.lat)!, longitude: Double(aBuilding.long)!)
			}
		}
		
		// Center map around user's current location
		map.setCenter(userLocation, animated: true)
	}
	
	// Function to set the user's coordinates
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// Get user's current coordinate - a custom location has been set up to set the user's location as the Ashton Building
		userLocation = manager.location!.coordinate
		// Add annotation for user's current location
		addAnnotation(name: "My Location", latitude: userLocation.latitude, longitude: userLocation.longitude)
		
		// Reload table data - buildings need to be re-sorted as the user location may have changed
		DispatchQueue.main.async { [unowned self] in
			self.sortBuildings()
			self.table.reloadData()
		}
	}
	
	// Function to add an annotation to the map
	func addAnnotation(name: String, latitude: Double, longitude: Double){
		// Specify coordinate of current place
		let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let region = MKCoordinateRegion(center: coordinate, span: span)
		map.setRegion(region, animated: true)
			
		// Add annotation for current place
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = name
		map.addAnnotation(annotation)
	}
	
	// Function for when a user clicks on an annotation on the map
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		// Set the building name to be the title of the annotation the user clicked on
		let buildingName: String = (view.annotation?.title!)!
		
		// Check annotation exists as key in dictionary (user may have clicked on 'my location' which should not link to any new view)
		if artworkByBuilding[buildingName] != nil {
			// If the building has multiple artworks - go to building list view controller, which lists the artwork located in that building - clicking on a row in this view will then go to detail view controller for that artwork
			if artworkByBuilding[buildingName]!.count > 1 {
				newBuildingListView(buildingName: buildingName)
			}
			else {	// If building has one artwork - go to the detail view controller for that piece of artwork
				newDetailView(buildingName: buildingName, artworkNum: 0)
			}
		}
	}
	
	// Function to determine number of sections to be displayed in the table
	func numberOfSections(in tableView: UITableView) -> Int {
		// If user is filtering the table (using search bar)
		if isFiltering(){
			// Return number of entries in the filtered buildings array
			return filteredBuildings.count
		}
		else {
			// Return number of entries in the buildings array (this is the total number of possible buildings the art could be in)
			return buildings.count
		}
	}
	
	// Function to determine section title
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		// If user is filtering the table (using search bar)
		if isFiltering(){
			// Return the name of the building in the filtered buildings array, at the index location of the current table section
			return filteredBuildings[section].name
		}
		else {
			// Return the name of the building in the buildings array, at the index location of the current table section
			return buildings[section].name
		}
	}
	
	// Function to determine the number of rows in each table section
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// If user is filtering the table (using search bar)
		if isFiltering(){
			// Return the number of artworks for that building from the artworksByBuilding dictionary, using the building name from the filtered buildings array as the index
			return artworkByBuilding[filteredBuildings[section].name]!.count
		}
		else {
			// Return the number of artworks for that building from the artworksByBuilding dictionary, using the building name from the buildings array as the index
			return artworkByBuilding[buildings[section].name]!.count
		}
	}
	
	// Function to return the cell for each row
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Cell style is subtitle to include the art title and artist
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "tableCell")
		
		// This is the section of the table the cell is in - determined by whether the user is filtering the table using the search bar
		var tableSection: String = ""
		// If the user is filtering the table (using the search bar)
		if isFiltering() {
			// Table section is the building name from the filtered buildings
			tableSection = filteredBuildings[indexPath.section].name
		}
		else {
			// Table section is the building name from the buildings
			tableSection = buildings[indexPath.section].name
		}
		
		// This is the title of the artwork
		cell.textLabel?.text = artworkByBuilding[tableSection]![indexPath.row].title
		// This is the artist of the artwork
		cell.detailTextLabel?.text = artworkByBuilding[tableSection]![indexPath.row].artist
		
		// Return the cell
		return cell
	}
	
	// Function for when user clicks on row in table - opens 'more info' view for that piece of artwork
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if isFiltering() {
			newDetailView(buildingName: filteredBuildings[indexPath.section].name, artworkNum: indexPath.item)
		}
		else {
			newDetailView(buildingName: buildings[indexPath.section].name, artworkNum: indexPath.item)
		}
	}
	
	func newDetailView(buildingName: String, artworkNum: Int){
		// Instantiate new DetailViewController
		let newView = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
		self.navigationController?.pushViewController(newView!, animated: true)
		
		// Section of table this cell is in - used to simplify later statements
		let tableSection = buildingName
		
		// Set the values for the new view
		newView!.artTitle = artworkByBuilding[tableSection]![artworkNum].title
		newView!.artImage = artworkByBuilding[tableSection]![artworkNum].fileName
		newView!.artist = artworkByBuilding[tableSection]![artworkNum].artist
		newView!.artYear = artworkByBuilding[tableSection]![artworkNum].yearOfWork
		newView!.artInfo = artworkByBuilding[tableSection]![artworkNum].Information
	}
	
	func newBuildingListView(buildingName: String){
		// Instantiate new DetailViewController
		let newView = storyboard?.instantiateViewController(withIdentifier: "BuildingListViewController") as? BuildingListViewController
		self.navigationController?.pushViewController(newView!, animated: true)
		
		// Section of table this cell is in - used to simplify later statements
		newView!.buildingName = buildingName
	}
	
}


// TO DO
/*

	10. sync app on startup?

*/
