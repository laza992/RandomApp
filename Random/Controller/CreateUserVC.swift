//
//  CreateUserVC.swift
//  Random
//
//  Created by developer on 28.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateUserVC: UIViewController {

//MARK: - Outlets
    @IBOutlet weak var emailTxt: AuthenticationTextField!
    @IBOutlet weak var passwordTxt: AuthenticationTextField!
    @IBOutlet weak var usernameTxt: AuthenticationTextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
    }
    
//MARK: - Button Actions
    @IBAction func createUserBtnTapped(_ sender: Any) {
        
        guard let email = emailTxt.text,
            let password = passwordTxt.text,
            let username = usernameTxt.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error creating user: \(error.localizedDescription)")
            }
            
            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            })
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USERNAME : username,
                DATE_CREATED : FieldValue.serverTimestamp()
            ]) { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
