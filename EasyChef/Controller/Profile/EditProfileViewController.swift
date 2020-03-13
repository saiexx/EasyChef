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
    
    @IBOutlet weak var editTableView: UITableView!
        
    let user = Auth.auth().currentUser
    let userDB = FirestoreReferenceManager.usersDB
    
    var imageUrl:URL?
    
    var name:String?
    var about:String?
    var style:String?
    var image:UIImage?
    
    
    struct Storyboard {
        static let image = "Image"
        static let profile = "Profile"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showUserProfile()
        setTableView()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        self.title = "Edit"
    }
    
    func setTableView() {
        editTableView.dataSource = self
        editTableView.delegate = self
        editTableView.rowHeight = UITableView.automaticDimension
        editTableView.estimatedRowHeight = editTableView.rowHeight
        editTableView.separatorColor = UIColor.clear
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        if image != nil {
            uploadPhotoToStorage()
        } else {
            imageUrl = user?.photoURL
            changeProfileValue()
        }
    }
    
    func showUserProfile() {
        userDB.document(user!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let about = document.get("about")
                let style = document.get("style")
                
                self.about = (about as! String)
                self.style = (style as! String)
                self.editTableView.reloadData()
            }
        }
        name = user?.displayName
        editTableView.reloadData()
    }
    
    func changeProfileValue() {
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = editTableView.cellForRow(at: indexPath) as! EditProfileTableViewCell
        
        name = cell.nameTextField.text
        style = cell.styleTextField.text
        about = cell.aboutTextField.text
        
        if cell.nameTextField.text!.isEmpty {
            name = user?.email
        }
        
        var imgUrl = user?.photoURL
        var imgUrlString = imgUrl?.absoluteString
        let email = user?.email
        
        func updateDatabase() {
            userDB.document(user!.uid).updateData([
                "about": self.about ?? "",
                "style": self.style ?? "",
                "email": email ?? "",
                "name": name ?? "",
                "imageUrl": imgUrlString as Any,
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document Successfully updated")
                   _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        let changeRequest = user?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.photoURL = imageUrl
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print(error)
                return
            }
            print("Profile Successfully Updated")
            imgUrl = self.user?.photoURL
            imgUrlString = imgUrl?.absoluteString
            updateDatabase()
        }
    }
    
    func uploadPhotoToStorage() {
        
        let randomNumber = Int.random(in: 0...10000)
        
        guard let data = image!.jpegData(compressionQuality: 1.0) else {
            print("error")
            return
        }
        
        let imageName = (user?.uid)!
        
        let imageReference = Storage.storage().reference()
            .child("userImage")
            .child(imageName)
            .child(imageName + String(randomNumber) + ".jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageReference.putData(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Upload successful")
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("Get download Url")
                self.imageUrl = url
                self.changeProfileValue()
            }
        }
    }
    
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func displayImagePickerControllerActionSheet() {
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
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        editTableView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }

}

extension EditProfileViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.image, for: indexPath) as! ProfileImageTableViewCell
            
            configureRoundProfileImage(imageView: cell.profileImageView)
            if image != nil {
                cell.profileImageView.image = image
            } else {
                if user?.photoURL == nil {
                    cell.profileImageView.image = #imageLiteral(resourceName: "default-profile-picture")
                } else {
                    cell.profileImageView.kf.setImage(with: user?.photoURL)
                }
            }
            
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.profile, for: indexPath) as! EditProfileTableViewCell
            
            cell.nameTextField.text = name ?? ""
            cell.styleTextField.text = style ?? ""
            cell.aboutTextField.text = about ?? ""
            
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }

}

extension EditProfileViewController: ProfileImageTableViewCellDelegate {
    func cameraButtonPressed() {
        displayImagePickerControllerActionSheet()
    }
}
