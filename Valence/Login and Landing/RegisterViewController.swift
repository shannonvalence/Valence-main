//
//  RegisterViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 1/31/21.
//
import UIKit
import Firebase



class RegisterViewController: UIViewController, UITextFieldDelegate {
    //MARK: - Class Properties
    ///@IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailWarningLabel: UILabel!
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var passWarningLabel: UILabel!
    @IBOutlet weak var passwordDescriptionStack: UIStackView!
    
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var confirmPassWarningLabel: UILabel!
    
    var authHandler = Firebase.Auth.auth()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        self.hideKeyboardWhenTappedAround()
        
        emailTextField.delegate = self
        passTextField.delegate = self
        confirmPassTextField.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Create Account Tapped
    @IBAction func createAccountTapped(_ sender: Any) {
        validateAllFields()
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        authHandler.createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code){
                    switch errCode {
                    case .invalidEmail:
                        self.emailWarningLabel.isHidden = false
                        self.emailWarningLabel.text = "Email is invalid."
                    case .emailAlreadyInUse:
                        self.emailWarningLabel.isHidden = false
                        self.emailWarningLabel.text = "Email is already in use."
                    case .weakPassword:
                        self.passWarningLabel.isHidden = false
                        self.passwordDescriptionStack.isHidden = false
                        self.passWarningLabel.text = "Password is too weak."
                    default:
                        print(errCode)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "toHome", sender: nil)
            }
        }
    }
    
    
    //MARK: - Should perform segue
    ///We are using this to check if the fields are valid, if they are go to the home-page.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        validateAllFields()
        
        if !passWarningLabel.isHidden ||
            !confirmPassWarningLabel.isHidden ||
            !emailWarningLabel.isHidden {
            return false
        }
        return true
    }
    
    //MARK: - Validation
    func validateAllFields() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let pass = passTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cPass = confirmPassTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if !isEmailValid(email: email) {
            emailWarningLabel.isHidden = false
            emailWarningLabel.text = "Email does not appear valid."
        } else { emailWarningLabel.isHidden = true }
        
        if !isPassValid(password: pass) {
            passWarningLabel.isHidden = false
            passwordDescriptionStack.isHidden = false
            passWarningLabel.text = "Password does not appear valid."
        } else {
            passWarningLabel.isHidden = true
            passwordDescriptionStack.isHidden = true
        }
        
        if !isConfirmPassValid(password: cPass) {
            confirmPassWarningLabel.isHidden = false
            confirmPassWarningLabel.text = "Passwords do not match."
        } else { confirmPassWarningLabel.isHidden = true }
        
    }
    
    func isEmailValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isPassValid(password: String) -> Bool {
        let password = password.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
    }
    
    func isConfirmPassValid(password: String) -> Bool {
        guard let pass = passTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cPass = confirmPassTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        
        if pass != cPass { return false }
        
        return true
    }
}

