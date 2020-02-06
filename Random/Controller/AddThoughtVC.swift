//
//  AddThoughtVC.swift
//  Random
//
//  Created by developer on 22.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AddThoughtVC: UIViewController {

// Outlets
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var thoughtTxt: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    
    // Variables
    private var selectedCategory = ThoughtCategory.funny.rawValue
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postBtn.layer.cornerRadius = 4
        thoughtTxt.layer.cornerRadius = 4
        thoughtTxt.text = "My random thought..."
        thoughtTxt.textColor = UIColor.lightGray
        thoughtTxt.delegate = self
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        categorySegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    // Button Actions
    @IBAction func categoryChanged(_ sender: Any) {
        switch categorySegment.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1:
            selectedCategory = ThoughtCategory.serious.rawValue
        default:
            selectedCategory = ThoughtCategory.crazy.rawValue
        }
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [
            CATEGORY : selectedCategory,
            NUM_COMMENTS : 0,
            NUM_LIKES : 0,
            THOUGHT_TXT: thoughtTxt.text!,
            TIMESTAMP : FieldValue.serverTimestamp(),
            USERNAME : self.username!,
            USER_ID: Auth.auth().currentUser?.uid ?? ""
            
        ]) { (error) in
            if let error = error {
                debugPrint("Error adding document: \(error)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension AddThoughtVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.darkGray
    }
}
