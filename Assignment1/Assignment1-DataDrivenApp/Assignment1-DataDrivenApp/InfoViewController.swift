//
//  InfoViewController.swift
//  Assignment1-DataDrivenApp
//
//  Created by Lucy Rogers on 06/11/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  COMP329 - Mobile Computing
//  Assignment 1 - Data Driven App
//
//	Author: Lucy Rogers
//  Student ID: 201078869
//

import UIKit
import CoreData


class InfoViewController: UIViewController {
	// Variables used for the information view
	var reportTitleText = ""
	var authors = ""
	var abstract = ""
	var url: URL?
	var reportYear = ""
	var reportID = ""
	var faveKey = ""
	
	// Outlets for the information view
	@IBOutlet weak var reportTitle: UILabel!
	@IBOutlet weak var reportAuthors: UILabel!
	@IBOutlet weak var reportAbstract: UITextView!
	@IBOutlet weak var faveSwitch: UISwitch!

	
	// Function used for when pdfButton ('View Full Report') is clicked - when clicked, relevant PDF is opened within the app.
	@IBAction func pdfButton(_ sender: Any) {
		let pdfURL = url!									// URL of PDF
		let webView = UIWebView(frame: self.view.frame)		// Create new web view
		webView.loadRequest(URLRequest(url: pdfURL))		// Load PDF in the web view
		let pdfViewController = UIViewController()			// Create new view controller for PDF
		pdfViewController.view.addSubview(webView)			// Add webView as subview of pdfView
		pdfViewController.title = "Full Report"				// Set title of the PDF view
		self.navigationController?.pushViewController(pdfViewController, animated: true)	// Add pdfView to current view's navigation controller
	}
	
	// Function used for when the switch button is clicked - this is used to indicate if the report is one of the user's favourites
	@IBAction func favouriteSwitch(_ sender: Any) {
		// Values for this report are used to calculate 'report' and 'key' - 'report' is the year and ID of the report, stored as a tuple, and the key is a concatenated string of these values which is used as the key in the favourites dictionary, if this particular report is added to the favourites
		let report = (reportYear, reportID)
		let key = "\(reportYear)" + "\(reportID)"
		
		if faveSwitch.isOn {								// If switch is turned on
			favourites.updateValue(report, forKey: key)		// Add report to the favourites dictionary
		}
		else {												// Switch is turned off
			favourites[key] = nil							// Remove report from the favourites dictionary
		}
	}
	
	// Function used for when view is loaded
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set the text values for the relevant labels of the view
		reportTitle.text = "\(reportTitleText)"
		reportAuthors.text = "\(authors)"
		reportAbstract.text = "\(abstract)"
		
		// Set the correct state for the switch button
		let key = "\(reportYear)" + "\(reportID)"
		if favourites[key] != nil {						// If report is in the favourites dictionary
			faveSwitch.setOn(true, animated: true)		// Switch button state is on
		}
		else {											// Report isn't in favourites dictionary
			faveSwitch.setOn(false, animated: true)		// Switch button state is off
		}
    }
}
