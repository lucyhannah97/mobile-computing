//
//  ViewController.swift
//  Guess
//
//  Created by Lucy Rogers on 11/10/2018.
//  Copyright © 2018 uk.ac.u5lr. All rights reserved.
//
//  Student: Lucy Rogers
//  Student ID: 201078869
//  COMP327 - Mobile Computing
//  Assignment 3 - App Portfolio
//  App 1 - Guessing Game
//

import UIKit

class ViewController: UIViewController {
	
    @IBOutlet weak var inputField: UITextField!		// Text Field - for user's guess
    @IBOutlet weak var answerStr: UILabel!			// Label - to display the answer
	// Variable to store the random value calculated, to represent the rolling of two dice
    let diceRoll = (Int.random(in: 1..<7)) + (Int.random(in: 1..<7))
    
    // Button - guess button, for the user to press once they have entered their guess into the text field
    @IBAction func guessButton(_ sender: Any) {
		// Variable to store the user's guess - this is the text in the text field
        guard let yourGuess = inputField.text else { return }
		var outputStr = ""
		if let yourGuessNum = Int(yourGuess){
			if (yourGuessNum == diceRoll){		// Correct answer
				outputStr = "Well done! The answer was \(diceRoll)!"
			}
			else {								// Incorrect answer
				outputStr = "Oh no! You guessed \(yourGuessNum), but the answer was \(diceRoll)"
			}
		}
		else {									// Int not entered
			outputStr = "Oops! You didn't enter a number! Please try again."
		}
        answerStr.text = outputStr			 	// Set text of label
		inputField.resignFirstResponder();	 	// Dismiss keyboard
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Include clear button on text field - user can quickly empty contents of text field while editing, or once finished editing
		inputField.clearButtonMode = .always
		// Contents of text field will clear when user begins editing
		inputField.clearsOnBeginEditing = true
    }
}
