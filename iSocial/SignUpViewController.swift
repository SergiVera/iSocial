//
//  SignUpViewController.swift
//  iSocial
//
//  Created by Sergi Vera Martínez on 28/03/2019.
//  Copyright © 2019 Sergi Vera Martínez. All rights reserved.
//

import UIKit
//Import the Firebase and SwiftKeychainWrapper libraries which are declared in Podfile file
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper

class SignUpViewController: UIViewController {
    
    //Variables of the textFields in the associated view
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    
    //Variable to handle the button addPhoto and signup
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    //Variable of the image View
    @IBOutlet weak var userImageView: UIImageView!
    
    //Variable where we store the image that user will choose as a profileimg
    //With the exclamation mark we force that variable to have a value
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedImage: UIImage!
    var validPhoto: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //We instantiate the imagePicker variable and we allow Editing
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
    }
    
    //Function to specify which view has to appear first, in this ViewController.swift
    override func viewDidAppear(_ animated: Bool) {
        //By default disable the signup button until the textfields are field
        self.signupButton.isEnabled = false
        //addTarget to textfields to monitor for the control event .editingChanged
        [emailField, passwordField, passwordField, repeatPasswordField].forEach({$0?.addTarget(self, action: #selector(editingChanged), for: .editingChanged)})
    }
    
    //Function that handles whether the textfields are empty or not
    @objc func editingChanged(_ textField: UITextField) {
        //Let's check the textfields
        guard
            let username = usernameField.text, !username.isEmpty,
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty,
            let repeatPassword = repeatPasswordField.text, !repeatPassword.isEmpty,
            (passwordField.text == repeatPasswordField.text),
            validPhoto != false
            else {
                signupButton.isEnabled = false
                return
        }
        signupButton.isEnabled = true
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
    
    //We call this function when the user taps the signup button
    @IBAction func signUpPressed(_ sender: Any) {
        //Save the emailField.text and passwordField.text into variables to use it instead of these large ones
        if let email = emailField.text, let password = passwordField.text {
                    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                        if error == nil {
                            self.storeUserData(userId: (authResult?.user.uid)!)
                            // create the alert
                            let alert = UIAlertController(title: "Done", message: "Your account has been created successfully", preferredStyle: UIAlertController.Style.alert)
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){
                                UIAlertAction in self.performSegue(withIdentifier: "toSignIn", sender: nil)
                            })
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            print("I'm inside the else in creating account")
                            self.showAlertButtonTapped(error: error!.localizedDescription)
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
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //Set the value of this image to selectedImage variable
            userImageView.image = image
        }
        //Close the imagePicker
        imagePicker.dismiss(animated: true, completion: nil)
        self.addPhotoButton.setTitle("Change Photo", for: .normal)
        self.validPhoto = true
    }
}
