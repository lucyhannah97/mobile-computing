//
//  ReportTableViewController.swift
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

struct techReport: Decodable {
	let year: String
	let id: String
	let owner: String?
	let authors: String
	let title: String
	let abstract: String?
	let pdf: URL?
	let comment: String?
	let lastModified: String
}

struct technicalReports: Decodable {
	let techreports: [techReport]
}

var favourites = [String: (String, String)]()	// Dictionary of favourite reports - the year and id of the report is stored to be able to identify it

class ReportTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var reportsOrdered = [String:[techReport]]()	// Dictionary used to group reports
	var yearsReverseSorted: [String] = []			// String array of publication years of reports - sorted in reverse order, so most recent year is first (2018)
	
	@IBOutlet weak var reportTable: UITableView!	// Table used to display reports
	
	// Function for when the view loads
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Decode the JSON file
		if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/techreports/data.php?class=techreports") {
			let session = URLSession.shared
			session.dataTask(with: url) { (data, response, err) in
				guard let jsonData = data else {
					return
				}
				do{
					let decoder = JSONDecoder()
					let reportList = try decoder.decode(technicalReports.self, from: jsonData)
					var years: [String] = []			// String array - years reports have been written in
					for aReport in reportList.techreports {		// For each report
						if(!(years.contains(aReport.year))){	// If year not already existing in year array
							years.append(aReport.year)			// Add year to array
						}
					}
					
					self.yearsReverseSorted = (years.sorted()).reversed()	// Sort the years in order, then reverse this order so the most recent year is first (2018)
					
					// For each 'year' in the array of sorted years, add to dictionary as key
					for aYear in self.yearsReverseSorted.reversed(){
						self.reportsOrdered[aYear] = []
					}
					
					// For each report in the array of tech reports, add to the value array in the dictionary under the correct year (key)
					for aReport in reportList.techreports {
						self.reportsOrdered[aReport.year]!.append(aReport)
					}
					
					// Reload table data
					DispatchQueue.main.async { [unowned self] in
						self.reportTable.reloadData()
					}
				} catch let jsonErr {								// Catch error
					print("Error decoding JSON", jsonErr)			// Error decoding JSON file
				}
			}.resume()
		}
	}

	// Function for when view appears - reloads table data
	override func viewDidAppear(_ animated: Bool) {
		reportTable.reloadData()
	}
	
	// Function to return the number of table sections - this is the total number of possible publication years for the reports (total number of elements in the 'years' array)
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.yearsReverseSorted.count
	}
	
	// Function to return the correct title for each of the table sections - this is the year of publication for that table section
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.yearsReverseSorted[section]
		return section
	}
	
	// Function to return the correct number of rows for each section - each section is a different year, so the number of rows is equal to the number of reports published in that year
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let section = self.yearsReverseSorted[section]
		return reportsOrdered[section]!.count
	}
	
	// Function to return the cell for each row - the style and text labels are also set before the cell is returned
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Cell style is set to subtitle, to allow display of title and authors of report
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "tableCell")
		
		// Section of table the cell is in
		let tableSection = yearsReverseSorted[indexPath.section]
		
		// If title is null, print title as [No Title]
		if (reportsOrdered[tableSection]![indexPath.row].title == ""){
			cell.textLabel?.text = "[No Title]"
		}
		else{	// If title has a value, set label to the title value
			cell.textLabel?.text = "\(reportsOrdered[tableSection]![indexPath.row].title)"
		}
		
		// Set the subtitle value to be the report's authors
		cell.detailTextLabel?.text = "\(reportsOrdered[tableSection]![indexPath.row].authors)"
		
		// The reportCell and reportKey values below are the values that would be stored in the 'favourites' dictionary if this report was marked as a favourite. The values are calculated for this report, and then compared to the 'favourites' dictionary to see if this report is a favourite
		let reportYear = reportsOrdered["\(tableSection)"]![indexPath.row].year
		let reportID = reportsOrdered["\(tableSection)"]![indexPath.row].id
		let reportCell = (year: reportYear, id: reportID)
		let reportKey = "\(reportCell.year)" + "\(reportCell.id)"
		
		if (favourites[reportKey] != nil) {			// If this report is a favourite
			// Highlight the cell with a blue background colour
			cell.backgroundColor = UIColor.init(displayP3Red: 197.0/255.0, green: 217.0/255.0, blue: 249.0/255.0, alpha: 255.0/255.0)
		}
		
		// Add arrow to right of cell, indicating there is a snew view when user clicks on cell
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	// Function for when user clicks on a cell in the table - they are taken to the 'Info' view where they can see more detailed information about the report they clicked on
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Instantiate new InfoViewController
		let newView = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
		self.navigationController?.pushViewController(newView!, animated: true)
		
		// Section of table this cell is in - used to simplify later statements
		let tableSection = yearsReverseSorted[indexPath.section]
		
		// Set the values of the report in the new view
		newView!.reportTitleText = reportsOrdered[tableSection]![indexPath.item].title
		newView!.authors = reportsOrdered[tableSection]![indexPath.item].authors
		newView!.abstract = reportsOrdered[tableSection]![indexPath.item].abstract ?? ""
		newView!.url = reportsOrdered[tableSection]![indexPath.item].pdf
		newView!.reportYear = reportsOrdered[tableSection]![indexPath.item].year
		newView!.reportID = reportsOrdered[tableSection]![indexPath.item].id
	}
}
