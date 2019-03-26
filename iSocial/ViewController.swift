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
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //Variable to handle the button addPhoto and signup/signin
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var signinSignupButton: UIButton!
    
    //Variable of the image View
    @IBOutlet weak var userImageView: UIImageView!
    
    //Variable where we store the image that user will choose as a profileimg
    //With the exclamation mark we force that variable to have a value
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //We instantiate the imagePicker variable and we allow Editing
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
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
        
        //By default disable the signup/signin button until the textfields are field, except username (optional)
        self.signinSignupButton.isEnabled = false
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
            signinSignupButton.isEnabled = false
            return
        }
        signinSignupButton.isEnabled = true
    }
    
    //Store user data
    func storeUserData(userId: String) {
        print("I'm inside storeUserData function")
        // Create a root reference
        let storageRef = Storage.storage().reference()
        let ref = Database.database().reference()
        
        if let imageData = userImageView.image!.jpegData(compressionQuality: 0.75) {
            
            //Uid of the image
            let imageUid = NSUUID().uuidString
            
            let metaData = StorageMetadata()
            
            storageRef.child(imageUid).putData(imageData, metadata: metaData) { (metadata, error) in
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    print("DownloadURL: ", downloadURL)
                    
                    //We will pass an array of values if there isn't an error uploading the file
                    let userData = [
                        "username": self.usernameField.text!,
                        "userImage": downloadURL
                    ] as [String: Any]
                    
                    ref.child("users").child(userId).setValue(userData)
                }
            }
        }
    }

    //We call this function when the user taps the button
    @IBAction func signInPressed(_ sender: Any) {
        //Save the emailField.text and passwordField.text into variables to use it instead of these large ones
        if let email = emailField.text, let password = passwordField.text {
            //Sign in
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                //Like Golang, if the error is different from nil
                //We only create the account if the username textField and imageView aren't nil
                if error != nil && !(self.usernameField.text?.isEmpty)! {
                    //Create Account
                    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                        if error == nil {
                            self.storeUserData(userId: (authResult?.user.uid)!)
                            KeychainWrapper.standard.set((authResult?.user.uid)!, forKey: "uid")
                            self.performSegue(withIdentifier: "toFeed", sender: nil)
                        } else {
                            print("I'm inside the else in creating account")
                            self.showAlertButtonTapped(error: error.debugDescription)
                        }
                    }
                } else {
                    //In this new version we have to acces to the variable user, and then user and its uid
                    KeychainWrapper.standard.set((user?.user.uid)!, forKey: "uid")
                    //We will go to the viewController whose identifier is toFeed
                    //We open a new viewController with performSegue method
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                }
            }
        }
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
    
    
    //Add Photo button is pressed
    @IBAction func getPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

//We add new funcionalities to our class, like pick the image and navigation
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //Set the value of this image to selectedImage variable
            userImageView.image = image
        }
        //Close the imagePicker
        imagePicker.dismiss(animated: true, completion: nil)
        self.addPhotoButton.setTitle("Change Photo", for: .normal)
    }
}

