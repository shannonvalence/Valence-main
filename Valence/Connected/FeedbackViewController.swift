//
//  FeedbackViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/4/21.
//

import Foundation
import UIKit
import SwiftUI

class FeedbackViewController: UIViewController, UITextViewDelegate {
    //MARK: - Class Properties
    ///@IBOutlets
    @IBOutlet weak var feedbackField: UITextView!
    
    
    ///Custom Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        feedbackField.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Text Field Function
    ///Clear the text when begin editing happens, only for the first time.
    func textViewDidBeginEditing(_ textView: UITextView) {
        let text = textView.text
        
        if text == "Enter your feedback here." {
            textView.text = ""
        }
    }
}

