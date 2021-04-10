//
//  ViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 1/25/21.
//

import UIKit
import Firebase
import SwiftUI




class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: - Class Properties
    ///@IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailWarningLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordWarningLabel: UILabel!
    @IBOutlet weak var rememberMeToggle: UISwitch!
    
    ///Used to verify all fields .
    ///Index 0 is Email
    ///Index 1 is Password
    
    
  
    var fieldValidStatus = [false, false]
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self

        rememberMeToggle.isOn = UserDefaults.standard.bool(forKey: "RememberMe")
        
        if UserDefaults.standard.bool(forKey: "RememberMe") {
            let user = Auth.auth().currentUser
            if user != nil {
                performSegue(withIdentifier: "toHome", sender: nil)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        validateAllFields()
        
        if !fieldValidStatus.contains(false) {
            guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let pass = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            
            signIn(email: email, password: pass)
        }
    }
    
    @IBAction func rememberToggled(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: "RememberMe")
    }
    
    //MARK: - Validation
    ///Simple validation check to ensure that the inputs are valid before
    ///wasting resources checking against Firebase.
    func validateAllFields() {
        
        ///Safely unwrap email and password, if it fails then
        ///return false, inputs are not valid.
        guard let emailText = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let passText = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        ///Check if text fields are empty.
        ///Split into separate statements to support warning labels.
        if emailText == "" {
            emailWarningLabel.isHidden = false
            emailWarningLabel.text = "Email cannot be blank."
            fieldValidStatus[0] = false
        } else {
            emailWarningLabel.isHidden = true
            fieldValidStatus[0] = true
        }
        
        if passText == "" {
            passwordWarningLabel.isHidden = false
            passwordWarningLabel.text = "Password cannot be blank."
            fieldValidStatus[1] = false
        } else {
            passwordWarningLabel.isHidden = true
            fieldValidStatus[1] = true
        }
        
        if !isValidEmail(emailText) {
            emailWarningLabel.isHidden = false
            emailWarningLabel.text = "Email doesn't appear to be valid."
            fieldValidStatus[0] = false
        } else {
            emailWarningLabel.isHidden = true
            fieldValidStatus[0] = true
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK: - Sign In
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error != nil {
                if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .wrongPassword:
                        strongSelf.passwordWarningLabel.isHidden = false
                        strongSelf.passwordWarningLabel.text = "Invalid password."
                    case .invalidEmail:
                        strongSelf.emailWarningLabel.isHidden = false
                        strongSelf.emailWarningLabel.text = "Invalid email."
                    case .userDisabled:
                        strongSelf.emailWarningLabel.isHidden = false
                        strongSelf.emailWarningLabel.text = "Account disabled."
                    default:
                        strongSelf.emailWarningLabel.isHidden = false
                        strongSelf.emailWarningLabel.text = "Account does not exist."
                    }
                }
            } else {
                strongSelf.performSegue(withIdentifier: "toHome", sender: nil)
            }
        }
    }
}





struct LoginViewController_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        /*@START_MENU_TOKEN@*/if #available(iOS 14.0, *) {
        
                Text("Hello, World!")
            
        } else {
            // Fallback on earlier versions
        }/*@END_MENU_TOKEN@*/
    }
}


