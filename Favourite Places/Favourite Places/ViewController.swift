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
import MapKit
import CoreData
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	// Outlets
	@IBOutlet weak var map: MKMapView!
	
	// Core Data
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var context: NSManagedObjectContext?
	
	// Location Manager
	let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Check if current place was added by user, or if need to use user's location to display on map
		if currentPlace == -1 {			// User pressed '+' button
			userLocation()				// User's current location (Ashton Building)
		} else {						// User clicked on a place from the list
			specifiedLocation()			// Location is in 'places' list added by user
		}
	}
	
	// Function to centre the map on the user's current location (set as the Ashton Building, as the simulator doesn't have real GPS)
	func userLocation(){
		locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
		}
		map.delegate = self
//		map.mapType = .standard
		map.isZoomEnabled = true					// Enable zoom
		map.isScrollEnabled = true					// Enable scroll
		if let coord = map.userLocation.location?.coordinate {
			map.setCenter(coord, animated: true)	// Centre map around user's coordinate
		}
	}
	
	// Function used to set the user's coordinate
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// Get user's current coordinate (following line commented as simulator doesn't have real GPS, so need to hardcode position on following line)
//		let locValue:CLLocationCoordinate2D = manager.location!.coordinate
		let locValue = CLLocationCoordinate2D(latitude: 53.406566, longitude: -2.966531)		// Hardcoded - Ashton Building
		
//		map.mapType = MKMapType.standard
		
		// Specify coordinate span & region on map
		let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
		let region = MKCoordinateRegion(center: locValue, span: span)
		map.setRegion(region, animated: true)
		
		// Add annotation to coordinate
		let annotation = MKPointAnnotation()
		annotation.coordinate = locValue
		annotation.title = "Current Location"
		annotation.subtitle = "Ashton Building"
		map.addAnnotation(annotation)
	}
	
	// Function to load a location on the map that is contained in the 'places' list - these locations have already been chosen and specified by the user previously
	func specifiedLocation(){
		// Getting values for the current place
		guard let name = places[currentPlace]["name"] else { return }	// Name of place
		guard let lat = places[currentPlace]["lat"] else { return }		// Latitude of place (string)
		guard let lon = places[currentPlace]["lon"] else { return }		// Longitude of place (string)
		guard let latitude = Double(lat) else { return }				// Convert latitude to double
		guard let longitude = Double(lon) else { return }				// Convert longitude to double
		
		// Specify coordinate of current place
		let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let region = MKCoordinateRegion(center: coordinate, span: span)
		map.setRegion(region, animated: true)							// Add to map
		
		// Add annotation for current place
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = name
		map.addAnnotation(annotation)									// Add to map
		
		// Long press gesture recognizer - for when the user wants to add a new place to the list
		let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
		uilpgr.minimumPressDuration = 2									// Minimum press of 2 seconds
		map.addGestureRecognizer(uilpgr)								// Add gesture recognizer to map
	}
	
	// Function for long press gesture recognizer - when the user wants to add a new place to the list
	@objc func longpress(gestureRecognizer: UIGestureRecognizer){
		if (gestureRecognizer.state == UIGestureRecognizer.State.began) {	// If start of long press
			
			// Add new coordinate for location pressed on map
			let touchPoint = gestureRecognizer.location(in: self.map)
			let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
			
			// Location selected and its title
			let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
			var title = ""
			CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
				if (error != nil) {
					print(error!)			// Print error
				} else {					// Obtain title for place selected
					if let placemark = placemarks?[0] {
						if placemark.subThoroughfare != nil {
							title += placemark.subThoroughfare! + " "
						}
						if placemark.thoroughfare != nil {
							title += placemark.thoroughfare!
						}
					}
				}
				
				// If we are unable to obtain a title for the place selected by the user
				if (title == "") {					// If no title for place chosen
					title = "Added \(NSDate())"		// Title is date added
				}
				
				// Add annotation for new coordinate
				let annotation = MKPointAnnotation()
				annotation.coordinate = newCoordinate
				annotation.title = title
				self.map.addAnnotation(annotation)		// Add to map
				
				// Add to list of places
				places.append(["name":title, "lat": String(newCoordinate.latitude), "lon": String(newCoordinate.longitude)])
				
				// Save to core data
				self.context = self.appDelegate.persistentContainer.viewContext
				let newPlace = NSEntityDescription.insertNewObject(forEntityName: "MyPlaces", into: self.context!) as! MyPlaces
				newPlace.setValue(title, forKey: "placeName")
				newPlace.setValue(String(newCoordinate.latitude), forKey: "latitude")
				newPlace.setValue(String(newCoordinate.longitude), forKey: "longitude")
				do {
					try self.context?.save()			// Save context
				} catch {
					print("Oops! Error saving this place to core data")
				}
			})
		}
	}
}
