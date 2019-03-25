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
import SwiftKeychainWrapper

class ViewController: UIViewController {
    
    //Variables of the textFields in the associated view
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //Variable of the image View
    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //We call this function when the user taps the button
    @IBAction func signInPressed(_ sender: Any) {
        //Save the emailField.text and passwordField.text into variables to use it instead of these large ones
        if let email = emailField.text, let password = passwordField.text {
            //Sign in
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                //Like Golang, if the error is different from nil
                if error != nil {
                    print("I'm inside if")
                    //Create Account
                } else {
                    print("I'm inside else")
                    //In this new version we have to acces to the variable user, and then user and its uid
                    KeychainWrapper.standard.set((user?.user.uid)!, forKey: "KEY_UID")
                    //We will go to the viewController whose identifier is toFeed
                    //We open a new viewController with performSegue method
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                }
            }
        }
    }
}

