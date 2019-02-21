//
//  ViewController.swift
//  One_two
//
//  Created by Eugene Ar on 21/02/2019.
//  Copyright © 2019 Kin. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate {
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var logoButtonView: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    
    let businessCard = BusinessCard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func updateView() {
        // hiding and rehiding elements
        self.qrCodeImageView.isHidden = !businessCard.isFilledInfo
        self.infoStackView.isHidden = !businessCard.isFilledInfo
        self.contactButton.isHidden = businessCard.isFilledInfo
        self.logoImageView.isHidden = !businessCard.isFilledLogo
        self.logoButtonView.isHidden = businessCard.isFilledLogo
        
        // Updating all labels and their hideness from businessCard
        // Hide label if it's empty
        self.nameLabel.text = self.businessCard.name
        self.nameLabel.isHidden = self.businessCard.name == ""

        self.roleLabel.text = self.businessCard.role
        self.roleLabel.isHidden = self.businessCard.role == ""
        
        self.phoneLabel.text = self.businessCard.phone
        self.phoneLabel.isHidden = self.businessCard.phone == ""
        
        self.mailLabel.text = self.businessCard.mail
        self.mailLabel.isHidden = self.businessCard.mail == ""
        
        self.siteLabel.text = self.businessCard.site
        self.siteLabel.isHidden = self.businessCard.site == ""
        
        self.qrCodeImageView.image = self.businessCard.qr
        
        self.logoImageView.image = self.businessCard.logo
    }
    
    // MARK - contacts
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("some contact picked")
        self.dismiss(animated: true, completion: nil)
        
        self.businessCard.updateContactInfo(using: contact)
        self.updateView()
    }
    
    @IBAction func setContactPressed(_ sender: UIButton) {
        
        func openContacts() {
            let contactPicker = CNContactPickerViewController.init()
            contactPicker.delegate = self
            
            self.present(contactPicker, animated: true, completion: nil)
        }
        
        // Configuring contacts
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if authStatus == CNAuthorizationStatus.notDetermined {
            let contactsStore = CNContactStore.init()
            contactsStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                if success {
                    openContacts()
                }
                else {
                    print("Not authorized")
                }
            })
        }
        else if authStatus == CNAuthorizationStatus.authorized {
            openContacts()
        }
    }
    
    // MARK - logo
    
    @IBAction func addLogoButtonPressed(_ sender: UIButton) {
        self.openLibrary()
        //TODO - should add taking photos from Documents
    }
    
    func openLibrary() {
        // Open PhotoLibrary to take picture for logo
        let logoImage = UIImagePickerController()
        logoImage.sourceType = .photoLibrary
        logoImage.allowsEditing = false
        logoImage.delegate = self
        self.present(logoImage, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Make it exactly the logoImageView height
                let height = CGFloat(self.logoImageView.frame.height)
                let ratio = height/image.size.height
                let width = CGFloat(image.size.width * ratio)
                let rect = CGRect(x: 0, y: 0, width: width, height: height)
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
                image.draw(in: rect)
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Hide block with button and show imageView with logo
                self.logoButtonView.isHidden = true
                self.logoImageView.isHidden = false
                
                self.logoImageView.image = resizedImage
                // update Logo in default storage
                self.businessCard.updateLogo(using: resizedImage!)
            }
            else {
                //Error message
            }
            self.dismiss(animated: true, completion: nil)
    }
}

