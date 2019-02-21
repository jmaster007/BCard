//
//  File.swift
//  One_two
//
//  Created by Eugene Ar on 21/02/2019.
//  Copyright © 2019 Kin. All rights reserved.
//

import Foundation
import Contacts
import UIKit

// A class to store and save info from card
class BusinessCard {
    var name: String
    var role: String
    var phone: String
    var mail: String
    var site: String
    var qr: UIImage
    var logo: UIImage
    var isFilledInfo = false
    var isFilledLogo = false
    
    struct keys {
        static let name = "name"
        static let role = "role"
        static let phone = "phone"
        static let mail = "mail"
        static let site = "site"
        static let qr = "qr"
        static let logo = "logo"
        static let isFilledInfo = "isFilledInfo"
        static let isFilledLogo = "isFilledLogo"
    }
    
    init() {
        if let  name = UserDefaults.standard.string(forKey: keys.name) {
            self.name = name
        } else { self.name = "" }
        
        if let role = UserDefaults.standard.string(forKey: keys.role) {
            self.role = role
        } else { role = "" }
        
        if let phone = UserDefaults.standard.string(forKey: keys.phone) {
            self.phone = phone
        } else { phone = "" }
        
        if let mail = UserDefaults.standard.string(forKey: keys.mail) {
            self.mail = mail
        } else { mail = "" }
        
        if let site = UserDefaults.standard.string(forKey: keys.site) {
            self.site = site
        } else { site = "" }
        
        if let qr = UserDefaults.standard.data(forKey: keys.qr) {
            self.qr = UIImage(data: qr)!
        } else { qr = UIImage() }

        if let logo = UserDefaults.standard.data(forKey: keys.logo) {
            self.logo = UIImage(data: logo)!
        } else { logo = UIImage() }
        
        let isFilledInfo = UserDefaults.standard.bool(forKey: keys.isFilledInfo)
        self.isFilledInfo = isFilledInfo
        let isFilledLogo = UserDefaults.standard.bool(forKey: keys.isFilledLogo)
        self.isFilledLogo = isFilledLogo
    }
    
    func updateContactInfo(using contact: CNContact) {
        // Update texts
        let name = "\(contact.givenName) \(contact.familyName)"
        UserDefaults.standard.set(name, forKey: keys.name)
        self.name = name
        
        let role = contact.jobTitle
        UserDefaults.standard.set(role, forKey: keys.role)
        self.role = role
        
        if let phone = contact.phoneNumbers.first?.value.stringValue {
            UserDefaults.standard.set(phone, forKey: keys.phone)
            self.phone = phone
        }
    
        if let mail = contact.emailAddresses.first?.value.decomposedStringWithCanonicalMapping {
            UserDefaults.standard.set(mail, forKey: keys.mail)
            self.mail = mail
        }

        if let site = contact.urlAddresses.first?.value.decomposedStringWithCanonicalMapping {
            UserDefaults.standard.set(site, forKey: keys.site)
            self.site = site
        }
        
        // Update filled switcher
        self.isFilledInfo = true
        UserDefaults.standard.set(self.isFilledInfo, forKey: keys.isFilledInfo)
        
        // Update QR-code
        do {
            let data = try CNContactVCardSerialization.data(with: [contact])
            if let image = generateQRCode(from: data) {
                // Updating info at default storage
                self.qr = image
                let qrData = image.pngData()
                UserDefaults.standard.set(qrData, forKey: keys.qr)
            } else {
                print("Cannot generate QR-code")
            }
        } catch {
            print("Cannot get contact data: \(error)")
        }
    }
    
    func generateQRCode(from data: Data) -> UIImage? {
        // Making QR-code from CIFilter
        let img: UIImage
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("M", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 4, y: 4)
            
            img = UIImage(ciImage: (filter.outputImage?.transformed(by: transform))!)
            
            UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
            img.draw(in: CGRect(origin: .zero, size: img.size))
            guard let redraw = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            
            return redraw
        }
        print("Cannot create filter")
        return nil
    }
    
    func updateLogo(using image: UIImage) {
        // Update Logo
        self.logo = image
        UserDefaults.standard.set(image.pngData(), forKey: keys.logo)
        // Update status
        self.isFilledLogo = true
        UserDefaults.standard.set(self.isFilledLogo, forKey: keys.isFilledLogo)
    }
}

