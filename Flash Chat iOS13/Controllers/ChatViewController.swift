//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        loadMessages()
    }
    
    func loadMessages(){
        db.collection("messages").order(by: "date").addSnapshotListener{ (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print(e.localizedDescription)
            }else {
                if let snapshotDocument = querySnapshot?.documents{
                    for doc in snapshotDocument {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let body = data["body"] as? String {
                            let newMessage = Message(sender: sender, body: body)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email  {
            db.collection("messages").addDocument(data: ["sender": messageSender, "body": messageBody, "date": Date().timeIntervalSince1970]) { (error) in
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }                    
                }
            }
        }
        
    }
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        cell.Label.text = messages[indexPath.row].body
        if messages[indexPath.row].sender  == Auth.auth().currentUser?.email{
            cell.LeftImageView.isHidden = true
            cell.RightImmageView.isHidden = false
            cell.MessageBubble.backgroundColor = UIColor(named: "BrandLightPurple")
            cell.Label.textColor = UIColor(named: "BrandPurple")
        }else{
            cell.LeftImageView.isHidden = false
            cell.RightImmageView.isHidden = true
            cell.MessageBubble.backgroundColor = UIColor(named: "BrandPurple")
            cell.Label.textColor = UIColor(named: "BrandLightPurple")
        }
        return cell
    }
}
