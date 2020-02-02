//
//  EditProfileViewController.swift
//  EasyChef
//
//  Created by Kasidid Wachirachai on 28/1/2563 BE.
//  Copyright © 2563 Kasidid Wachirachai. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var styleTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
        
    let user = Auth.auth().currentUser
    let userDB = FirestoreReferenceManager.usersDB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showUserProfile()
        configureRoundProfileImage(imageView: profileImageView)
        self.title = "Edit"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileImageView.kf.setImage(with: user?.photoURL)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        changeProfileValue()
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        showImagePickerControllerActionSheet()
    }
    
    func showUserProfile() {
        userDB.document(user!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let about = document.get("about")
                let style = document.get("style")
                
                self.aboutTextField.text = (about as! String)
                self.styleTextField.text = (style as! String)
            }
        }
        nameTextField.text = user?.displayName
    }
    
    func changeProfileValue() {
        var newName:String?
        let newAbout = aboutTextField.text
        let newStyle = styleTextField.text
        
        if nameTextField.text!.isEmpty {
            newName = user?.email
        } else {
            newName = nameTextField.text
        }
        
        let changeRequest = user?.createProfileChangeRequest()
        changeRequest?.displayName = newName
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print(error)
                return
            }
            print("Display Name Successfully Updated")
        }
        
        userDB.document(user!.uid).updateData([
            "about": newAbout ?? "",
            "style": newStyle ?? ""
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document Successfully updated")
                _ = self.navigationController?.popViewController(animated: true)

            }
        }
    }


}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (action) in
            self.showImagePicker(sourceType: .photoLibrary)
        })
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.showImagePicker(sourceType: .camera)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
