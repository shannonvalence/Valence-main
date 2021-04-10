//
//  RecoverAcctViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 1/31/21.
//
import UIKit
import FirebaseAuth

class RecoverAcctViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailinputField: UITextField!
    @IBOutlet weak var emailWarningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailinputField.delegate = self
        
    }
    
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    @IBAction func resetTapped(_ sender: Any) {
        emailWarningLabel.isHidden = false
        
        guard let email = emailinputField.text else {
            emailWarningLabel.text = "Something went wrong with your email."
            emailWarningLabel.textColor = .red
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [self] (error) in
            if error != nil {
                emailWarningLabel.text = error?.localizedDescription
                emailWarningLabel.textColor = .red
            } else {
                emailWarningLabel.text = "Please check your email for a password reset link."
                emailWarningLabel.textColor = .green
            }
            
            emailinputField.text = ""
        }
    }
    
}
