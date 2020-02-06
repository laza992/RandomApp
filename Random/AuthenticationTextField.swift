//
//  AuthenticationTextField.swift
//  Shyft
//
//  Created by Milos Mladenovic on 8/23/19.
//  Copyright © 2019 Milos Mladenovic. All rights reserved.
//

import UIKit

class AuthenticationTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.init(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.font = UIFont(name: "Avenir-Next Regular", size: 15)
        self.adjustsFontSizeToFitWidth = true
        let placeholderColor = UIColor.darkGray
        let rawString = attributedPlaceholder?.string != nil ? attributedPlaceholder!.string : ""
        let str = NSAttributedString(string: rawString, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        self.attributedPlaceholder = str
    }
    // Placeholder text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
    
    // Editable text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
}
