//
//  UpdateCommentsVC.swift
//  Random
//
//  Created by developer on 30.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentsVC: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    
    // MARK: - Variables
    
    var commentData : (comment: Comment, thought: Thought)!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTxt.layer.cornerRadius = 10
        updateBtn.layer.cornerRadius = 10
        commentTxt.text = commentData.comment.commentTxt
    }
    
    // MARK: - Button Actions
    
    @IBAction func updateTapped(_ sender: Any) {
        Firestore.firestore().collection(THOUGHTS_REF).document(commentData.thought.documentId).collection(COMMENTS_REF).document(commentData.comment.documentId).updateData([COMMENT_TXT : commentTxt.text!]) { (error) in
            if let error = error {
                debugPrint("Unable to update comment: \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
