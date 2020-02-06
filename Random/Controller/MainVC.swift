//
//  MainVC.swift
//  Random
//
//  Created by developer on 22.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

enum ThoughtCategory: String {
    case serious = "serious"
    case funny = "funny"
    case crazy = "crazy"
    case popular = "popular"
}

class MainVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    
    private var thoughts = [Thought]()
    private var thoughtsCollectionRef: CollectionReference!
    private var thoughtsListener: ListenerRegistration!
    private var selectedCategory = ThoughtCategory.funny.rawValue
    private var handle: AuthStateDidChangeListenerHandle?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        thoughtsCollectionRef = Firestore.firestore().collection(THOUGHTS_REF)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                self.present(loginVC, animated: true, completion: nil)
            } else {
                self.setListener()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if thoughtsListener != nil {
            thoughtsListener.remove()
        }
    }
    
    //MARK: - Functions
    
    func setListener() {
        
        if selectedCategory == ThoughtCategory.popular.rawValue {
            thoughtsListener = thoughtsCollectionRef
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                    debugPrint("Error fetching docs:\(error)")
                    } else {
                self.thoughts.removeAll()
                self.thoughts = Thought.parseData(snapshot: snapshot)
                self.tableView.reloadData()
            }
            }
        } else {
            thoughtsListener = thoughtsCollectionRef
                .whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    debugPrint("Error fetching docs:\(error)")
                } else {
                    self.thoughts.removeAll()
                    self.thoughts = Thought.parseData(snapshot: snapshot)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // get from Firebase Doc
    func delete(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()) {
        // Limit quewry to avoid out of memory errors of large collections
        // When deleting a collection quaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            // an error occurred.
            guard let docset = docset else {
                completion(error)
                return
            }
            // There's nothing to delete
            guard docset.count > 0 else {
                completion(nil)
                return
            }
            
            let batch = collection.firestore.batch()
            docset.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { (batchError) in
                if let batchError = batchError {
                    // Stop the deletion process and handle the error, Some elements may have been deleted
                    completion(batchError)
                } else {
                    self.delete(collection: collection, batchSize: batchSize, completion: completion)
                }
            }
        }
    }
    
    //MARK: - Button Actions
    
    @IBAction func categoryChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                selectedCategory = ThoughtCategory.funny.rawValue
            case 1:
                selectedCategory = ThoughtCategory.serious.rawValue
            case 2:
                selectedCategory = ThoughtCategory.crazy.rawValue
            default:
                selectedCategory = ThoughtCategory.popular.rawValue
            }
        
        thoughtsListener.remove()
        setListener()
        }

    @IBAction func logoutTapped(_ sender: Any) {
        
        let logoutPopup = UIAlertController(title: "logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let firebaseAuth = Auth.auth()
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do {
                try firebaseAuth.signOut()
            } catch let signoutError as NSError {
                debugPrint("Error signing out: \(signoutError)")
            }
        }
            logoutPopup.addAction(cancelAction)
            logoutPopup.addAction(logoutAction)
            present(logoutPopup, animated: true, completion: nil)
        }
}

    //MARK: - Extensions

extension MainVC: UITableViewDataSource, UITableViewDelegate, ThoughtDelegate {
    
    func thoughtOptionsTapped(thought: Thought) {
        
        let alert = UIAlertController(title: "Delete", message: "Do you want do delete your thought?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Thought", style: .default) { (action) in
            // delete
            
            self.delete(collection: Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).collection(COMMENTS_REF)) { (error) in
                if let error = error {
                    debugPrint("Could not delete subcollection: \(error.localizedDescription)")
                } else {
                    
                    Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).delete { (error) in
                        if let error = error {
                            debugPrint("Could not delete: \(error.localizedDescription)")
                        } else {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ThoughtCell", for: indexPath) as? ThoughtCell {
            
            cell.configureCell(thought: thoughts[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: thoughts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let thought = sender as? Thought {
                    destinationVC.thought = thought
                }
            }
        }
    }
}

