//
//  FeedbackViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/4/21.
//
import Foundation
import UIKit
import Firebase

class FeedbackViewController: UIViewController, UITextViewDelegate {
    //MARK: - Class Properties
    ///@IBOutlets
    @IBOutlet weak var feedbackField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    ///Custom Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        feedbackField.delegate = self
    }
    
    //MARK: - Text Field Function
    ///Clear the text when begin editing happens, only for the first time.
    func textViewDidBeginEditing(_ textView: UITextView) {
        sendButton.isEnabled = true
        if textView.text == "Enter your feedback here." {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "" {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func sendFeedback() {
        let deviceId = KeychainHelper.shared.getDeviceId()
        let dbRef = Database.database().reference()
        dbRef.child("UserFeedback").child(deviceId).child(Date().getDateInStringPT).setValue(feedbackField.text) { error, _ in
            var alertTitle = ""
            var alertMessage: String? = nil
            if error != nil {
                alertTitle = "Feedback could not be saved"
                alertMessage = "\(error.debugDescription)"
            } else {
                alertTitle = "Feedback has been sent successfully."
                self.feedbackField.text = ""
            }
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
    }
}
