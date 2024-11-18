//
//  RegistrationController.swift
//  MyApp
//
//  Created by Алексей Сушкевич on 15.11.24.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    private let registrationView = RegistrationUIView()
    private var user: User?
    
    override func loadView() {
        view = registrationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Registration"
        
        registrationView.registerButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        registrationView.usernameTextField.text = ""
        registrationView.passwordTextField.text = ""
    }
    
    @objc private func loginButtonTapped() {
        guard let username = registrationView.usernameTextField.text,
              let password = registrationView.passwordTextField.text else {
            showAlert(title: "Error", message: "Username and password cannot be empty.")
            return
        }
        
        do {
            user = try User(username: username, password: password)
            
            try user?.save()
            showAlert(title: "Success", message: "User saved successfully.")
        } catch User.UserError.usernameAlreadyExists {
            showAlert(title: "Error", message: "This username already exists.")
        } catch User.UserError.emptyUsername {
            showAlert(title: "Error", message: "Username cannot be empty.")
        } catch User.UserError.invalidPasswordLength {
            showAlert(title: "Error", message: "Password must be between 8 and 32 characters.")
        } catch {
            showAlert(title: "Error", message: "Unexpected error: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
