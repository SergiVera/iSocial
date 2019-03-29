//
//  ViewController.swift
//  iSocial
//
//  Created by Sergi Vera Martínez on 24/03/2019.
//  Copyright © 2019 Sergi Vera Martínez. All rights reserved.
//

import UIKit
//Import the Firebase and SwiftKeychainWrapper libraries which are declared in Podfile file
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper

class ViewController: UIViewController {
    
    //Variables of the textFields in the associated view
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //Variable to handle the signin button
    @IBOutlet weak var signinButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Function to specify which view has to appear first, in this ViewController.swift
    override func viewDidAppear(_ animated: Bool) {
        //We see inLoad if we have the KEY in memory due to a previous Sign in or Sign up
        //Like in go, we can ommit the returned string with _
        if let returned = KeychainWrapper.standard.string(forKey: "uid") {
            print("I'm inside if in viewDidLoad: ", returned)
            //The meaninig of self stands for this in other languages
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
        
        //By default disable the signin button until the textfields are field
        self.signinButton.isEnabled = false
        //addTarget to textfields to monitor for the control event .editingChanged
        [emailField, passwordField].forEach({$0?.addTarget(self, action: #selector(editingChanged), for: .editingChanged)})
    }
    
    //Function that handles whether the textfields are empty or not
    @objc func editingChanged(_ textField: UITextField) {
        //Let's check the textfields
        guard
        let email = emailField.text, !email.isEmpty,
        let password = passwordField.text, !password.isEmpty
        else {
            signinButton.isEnabled = false
            return
        }
        signinButton.isEnabled = true
    }

    //We call this function when the user taps the signin button
    @IBAction func signInPressed(_ sender: Any) {
        //Save the emailField.text and passwordField.text into variables to use it instead of these large ones
        if let email = emailField.text, let password = passwordField.text {
            //Sign in
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                //Like Golang, if the error is different from nil
                //We only create the account if the username textField and imageView aren't nil
                if error != nil {
                    //Show the error
                    self.showAlertButtonTapped(error: error!.localizedDescription)
                } else {
                    //In this new version we have to acces to the variable user, and then user and its uid
                    KeychainWrapper.standard.set((user?.user.uid)!, forKey: "uid")
                    //We will go to the viewController whose identifier is toFeed
                    //We open Feed viewController with performSegue method
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                }
            }
        }
    }
    
    //We call this function when the user taps the signup button
    @IBAction func signUpPressed(_ sender: Any) {
        //We open SignUp viewController with performSegue method
        self.performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    
    //Show an alert if there's an error creating the account
    func showAlertButtonTapped(error: String) {
        
        // create the alert
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}

