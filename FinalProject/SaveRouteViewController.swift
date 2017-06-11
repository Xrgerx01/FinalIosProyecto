//
//  SaveRouteViewController.swift
//  FinalProject
//
//  Created by Roger Chiroque on 17/07/16.
//  Copyright © 2016 Roger Chiroque. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class SaveRouteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate let picker = UIImagePickerController()
    
    var context: NSManagedObjectContext? = nil
    var location: CLLocation = CLLocation()
    var capturedImage: UIImage? = nil
    public var capturedPoints: [String: CLLocation] = [String: CLLocation]()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageSelector: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func backgroundTap(_ sender: UIControl) {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @IBAction func selectImageAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 1:
                picker.sourceType = UIImagePickerControllerSourceType.camera
                present(picker, animated: true, completion: nil)
            case 2:
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                present(picker, animated: true, completion: nil)
            default:
                capturedImage = nil
                imageView.image = nil
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        if nameTextField.text == ""{
            sendAlert("Error", message: "Debes ingresar al menos nombre a la ruta.")
        } else {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Route", into: self.context!)
            entity.setValue(nameTextField.text, forKey: "name")
            entity.setValue(descriptionTextView.text, forKey: "descript")
            entity.setValue(convertPointsToString(), forKey: "locationPoints")
            
            if let image = capturedImage{
                entity.setValue(UIImagePNGRepresentation(image), forKey: "image")
            }
            
            do {
                try self.context?.save()
                let nav = self.navigationController
                nav?.performSegue(withIdentifier: "routeSegue", sender: self)
            } catch{}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        picker.delegate = self
        
        self.context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        nameTextField.text = "";
        descriptionTextView.text = "";
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageView.image == nil {
            imageSelector.selectedSegmentIndex = 0
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        capturedImage = image
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func convertPointsToString() -> String {
        var stringPoints = ""
        
        for (name,point) in capturedPoints {
            stringPoints += name + ":" + String(point.coordinate.latitude) + ":" + String(point.coordinate.longitude) + "|"
        }
        return stringPoints
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func sendAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK",
                                   style: UIAlertActionStyle.cancel) { _ in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
