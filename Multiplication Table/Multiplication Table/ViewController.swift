//
//  ViewController.swift
//  Multiplication Table
//
//  Created by Lucy Rogers on 18/10/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  Student: Lucy Rogers
//  Student ID: 201078869
//  COMP327 - Mobile Computing
//  Assignment 3 - App Portfolio
//  App 2 - Multiplication Table
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var inputNum: UITextField!	// Text field to gather user input
	@IBOutlet weak var myTable: UITableView!	// Table to display multiplications
	
	let multiplyBy = Array(1...20)		// Array of numbers the user's input needs to be multiplied by
	var answers: [Int] = []				// Array to store answers from the multiplications

	// When 'Go' button is pressed
	@IBAction func goButton(_ sender: Any) {
		// User input is the value entered in the text field by the user, default value is -1 until the user has entered a value
		guard let inputByUser = inputNum.text else {return}
		if let userInput = Int(inputByUser) {		// User input was integer
			// For loop to calculate answer of multiplication, and update answers stored in answers array
			for i in 0...19 {
				answers[i] = multiplyBy[i] * userInput
			}
		}
		else {		// Popup alert to user detailing issue and asking for numeric input
			let alert = UIAlertController(title: "Oops!", message: "You did not enter a positive integer - please close this message and try again.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
				switch action.style{
					case .default:
						print("default")
					case .cancel:
						print("cancel")
					case .destructive:
						print("destructive")
				}
			}))
			self.present(alert, animated: true, completion: nil)
			inputNum.text = ""				// Empty text field
		}
		inputNum.resignFirstResponder()		// To hide keyboard
		myTable.reloadData()				// Reload table data
	}
	
	// Function to calculate number of rows in the table
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return multiplyBy.count 	// Number of rows is equal to the number of multipliers (20)
	}
	
	// Function to set the cell value for each row
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Default cell style
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "myCell")
		// User input is the value entered in the text field by the user, default value is -1 until the user has entered a value
		let userInput = Int(inputNum.text!) ?? -1
		// For loop to calculate answer and append to answers array
		for i in 1...20 {
			answers.append(i * userInput)
		}
		
		var answerString: String		// String used to print multiplication and answer
		
		// If user input variable is the default value, -1 (user has not entered an input value)
		if (userInput == -1){
			answerString = ""				// Answer string is blank
			myTable.separatorStyle = .none	// No separators in table
			// The table will appear blank as user has not yet entered a value
		}
		else {		// User has entered a value
			answerString = String(inputNum.text!) + " x " + String(multiplyBy[indexPath.item]) + " = " + String(answers[indexPath.item])		// Answer string is updated with relevant values
			myTable.separatorStyle = .singleLine	// Table row separator is added
		}
		cell.textLabel?.text = answerString			// Text label of cell is equal to answer string
		return cell									// Cell is returned
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		inputNum.clearButtonMode = .always			// Include clear button in text field
		inputNum.clearsOnBeginEditing = true		// Text field contents are cleared when user edits it
	}
}
