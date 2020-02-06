//
//  LoginVC.swift
//  Random
//
//  Created by developer on 28.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailTxt: AuthenticationTextField!
    @IBOutlet weak var passwordTxt: AuthenticationTextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createUserBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUserBtn.layer.cornerRadius = 10
        loginBtn.layer.cornerRadius = 10
        
    }
    
    // Button Actions
    @IBAction func loginBtnTapped(_ sender: Any) {
        guard let email = emailTxt.text,
            let password = passwordTxt.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signig in \(error)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


