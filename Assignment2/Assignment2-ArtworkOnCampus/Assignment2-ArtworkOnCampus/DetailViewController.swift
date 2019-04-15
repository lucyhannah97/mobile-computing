//
//  DetailViewController.swift
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
import CoreData

class DetailViewController: UIViewController {
	// Variables Used
	var artTitle = ""
	var artImage = ""
	var artist = ""
	var artYear = "Unknown"
	var artInfo = ""
	var imageURLStart = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artwork_images/"
	
	// Outlets
	@IBOutlet weak var artworkTitle: UILabel!
	@IBOutlet weak var artworkImage: UIImageView!
	@IBOutlet weak var artworkArtist: UILabel!
	@IBOutlet weak var artworkYear: UILabel!
	@IBOutlet weak var artworkInfo: UITextView!
	
	// Core Data
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var context: NSManagedObjectContext?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Retrieve artwork image and artwork info from core data (if exists)
		context = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Art")
		fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))
		fetchRequest.returnsObjectsAsFaults = false
		do {
			let results = try context?.fetch(fetchRequest)
			// If there are results
			if (results?.count)! > 0 {
				var inCoreData = false
				// For each result fetched from core data
				for i in 0..<(results?.count)! {
					let result = results?[i] as! Art
					// Get the title
					let resultTitle = result.name ?? "title"
					// If the title in core data matches the title of the artwork the user clicked on
					if (artTitle == resultTitle) {
						// Fetch artwork info from core data
						artInfo = result.info ?? "info"
						// Fetch image from core data
						let image: Data = result.image!
						let decodedImage = UIImage(data: image)
						// Set image of view
						artworkImage.image = decodedImage
						// Change boolean to true (this artwork was a result in core data)
						inCoreData = true
						continue
					}
				}
				// If the artwork clicked on by the user was not found in core data (i.e. they have not clicked on this artwork before)
				if !inCoreData {
					downloadImage()
				}
			} else {	// No results in core data
				print("No results")
				// Need to download image for this artwork
				downloadImage()
			}
		} catch {
			print("Couldn't fetch results")
		}
		// Set the text labels for the view (artwork title, artist, year etc.)
		setLabels()
	}
	
	// Function to download the image of the artwork
	func downloadImage(){
		// Set image URL
		let fullURL = imageURLStart + artImage
		let imageURL = URL(string: fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
		
		let session = URLSession(configuration: .default)
		let getImage = session.dataTask(with: imageURL!) { (data, response, error) in
			// If there is any error
			if let e = error {
				// Print error message
				print("Error Occurred: \(e)")
			}
			else {
				// Check response contains image
				if (response as? HTTPURLResponse) != nil {
					if let imageData = data {
						// Get & display image
						let image = UIImage(data: imageData)
						DispatchQueue.main.async { [unowned self] in
							// Set the image of the view
							self.artworkImage.image = image
							
							// Save the image to core data
							self.context = self.appDelegate.persistentContainer.viewContext
							let newArt = NSEntityDescription.insertNewObject(forEntityName: "Art", into: self.context!) as! Art
							newArt.setValue(self.artTitle, forKey: "name")
							newArt.setValue(self.artInfo, forKey: "info")
							newArt.setValue(imageData, forKey: "image")
							
							// Try to save & catch error (if error occurs)
							do {
								try self.context?.save()
								print("Saved image to context")
							} catch {
								print("Error saving to core data")
							}
						}
					}
					else {
						print("Image file is currupted")
					}
				} else {
					print("No response from server")
				}
			}
		}
		
		// Download image
		getImage.resume()
	}
	
	// Function to set the text for the labels in the view
	func setLabels(){
		artworkTitle.text = artTitle
		artworkArtist.text = artist
		artworkYear.text = artYear
		artworkInfo.text = artInfo
	}
}
