//
//  NewRestaurantControllerTableViewController.swift
//  FoodPin
//
//  Created by 任红雷 on 3/28/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import CoreData

class NewRestaurantControllerTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var restaurant:RestaurantMO!
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(segue: UIStoryboardSegue){
        var emptyFields:[String] = []
        var invalid: Bool = false
        
        if let phophotoImage = photoImageView.image{
            if phophotoImage.accessibilityIdentifier == "photo"{
            emptyFields.append("Photo")
                invalid = true
            }
        }
        if nameTextField.text == ""{
            emptyFields.append("Name")
            invalid = true
        }
        if typeTextField.text == ""{
            emptyFields.append("Type")
            invalid = true
        }
        if addressTextField.text == ""{
            emptyFields.append("Address")
            invalid = true
        }
        if phoneTextField.text == ""{
            emptyFields.append("Phone")
            invalid = true
        }
        if descriptionTextView.text == ""{
            emptyFields.append("Description")
            invalid = true
        }
        if invalid{
            let emptyString:String = emptyFields.joined(separator: ", ")
            
            let alertMessage = UIAlertController(title: "Invalid Fields", message: "Please input: \(emptyString)", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
        else{
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            {
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                restaurant.name = nameTextField.text
                restaurant.type = typeTextField.text
                restaurant.location = addressTextField.text
                restaurant.phone = phoneTextField.text
                restaurant.summary = descriptionTextView.text
                restaurant.isVisited = false
                
                if let restaurantImage = photoImageView.image{
                    restaurant.image = restaurantImage.pngData()
                }
                print("Saving data to context")
                appDelegate.saveContext()
            }
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }

    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }

    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }

    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure navigation bar appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60, alpha: 1.0)]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let photoSourceController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
                (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
                (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            photoSourceController.addAction(cameraAction)
            photoSourceController.addAction(photoLibraryAction)
            
            // For ipad
            if let popoverController = photoSourceController.popoverPresentationController{
                if let cell = tableView.cellForRow(at: indexPath){
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(photoSourceController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
